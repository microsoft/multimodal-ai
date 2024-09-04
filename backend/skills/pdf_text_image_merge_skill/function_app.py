import os
import logging
import json
import azure.functions as func
from azure.identity import DefaultAzureCredential
from core.pdfparser import DocumentAnalysisParser
from core.processor import Processor
from core.textsplitter import SentenceTextSplitter

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="pdf_text_image_merge_skill", methods=[func.HttpMethod.POST])
async def pdf_text_image_merge_skill(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        body = json.dumps(req.get_json())
    except ValueError:
        return func.HttpResponse(
            "Invalid body",
            status_code=400
        )

    if body:
        result = await compose_response(body)
        return func.HttpResponse(result, mimetype="application/json")
    else:
        return func.HttpResponse(
            "Invalid body",
            status_code=400
        )


async def compose_response(json_data):
    values = json.loads(json_data)['values']

    # Prepare the Output before the loop
    results = {}
    results["values"] = []

    for value in values:
        outputRecord = await transform_value(value)
        if outputRecord != None:
            results["values"].append(outputRecord)
    # Keeping the original accentuation with ensure_ascii=False
    return json.dumps(results, ensure_ascii=False)


async def transform_value(value):
    try:
        recordId = value['recordId']
    except AssertionError as error:
        return None

    # Validate the inputs
    try:
        assert ('data' in value), "'data' field is required."
        data = value['data']
        assert ('imageEmbedding' in data), "'imageEmbedding' field is required in 'data' object."
        assert ('url' in data), "'url' field is required in 'data' object."
    except AssertionError as error:
        return (
            {
                "recordId": recordId,
                "data": {},
                "errors": [{"message": "Error:" + error.args[0]}]
            })
    try:

        document_intelligence_service = os.getenv('DOCUMENT_INTELLIGENCE_SERVICE')
        credential = DefaultAzureCredential()

        parser = DocumentAnalysisParser(
            endpoint=f"https://{document_intelligence_service}.cognitiveservices.azure.com/",
            credential=credential)

        splitter=SentenceTextSplitter()

        processor = Processor(file_parser=parser, file_splitter=splitter)
        split_pages = await processor.process(data["url"])

        filename = data["url"].split('/')[-1]

        enriched_pages = []
        for split_page in split_pages:
            name_part, _ = os.path.splitext(filename)

            enriched_page = {
                "sourcepage": f"{name_part}-{split_page.page_num}.jpg",
                "sourcefile": filename,
                "storageUrl": data["url"],
                "content": split_page.text,
                "imageEmbedding": data["imageEmbedding"][split_page.page_num]
            }

            enriched_pages.append(enriched_page)

    except Exception as e:
        logging.error(e)
        return (
            {
                "recordId": recordId,
                "errors": [{"message": "Could not complete operation for record."}]
            })

    return ({
            "recordId": recordId,
            "data": {
                "enrichedPages": enriched_pages
            }
            })
