import os
import logging
import json
import base64
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="image_store_skill", methods=[func.HttpMethod.POST])
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
        assert ('images' in data), "'images' field is required in 'data' object."
        assert ('filename' in data), "'filename' field is required in 'data' object."
    except AssertionError as error:
        return (
            {
                "recordId": recordId,
                "data": {},
                "errors": [{"message": "Error:" + error.args[0]}]
            })
    try:
        account_url = os.getenv("STORAGE_ACCOUNT_URL")
        container_name = os.getenv("BLOB_CONTAINER_NAME")

        credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(account_url, credential=credential)
        original_file = data["filename"]

        image_urls = []
        for i, image in enumerate(data["images"]):
            content_bytes = base64.b64decode(image["data"])

            name_part, _ = os.path.splitext(original_file)
            blob_name = f"{name_part}-{i}.jpeg"

            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
            blob_client.upload_blob(content_bytes, blob_type="BlockBlob")

            image_urls.append(f"{account_url}/{container_name}/{blob_name}")

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
                "urls": image_urls
            }
            })
