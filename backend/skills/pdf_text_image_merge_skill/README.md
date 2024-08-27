# Sample usage

```json
"skills": [
    {
      "@odata.type": "#Microsoft.Skills.Custom.WebApiSkill",
      "name": "pdf_text_image_merge_skill",
      "description": "A custom skill that combines image embeddings with corresponding PDF pages and stores the images",
      "context": "/document",
      "uri": "https://[host]/api/pdf_text_image_merge_skill",
      "httpMethod": "POST",
      "inputs": [
        {
          "name": "imageEmbedding",
          "source": "/document/normalized_images/*/imageEmbedding"
        },
        {
          "name": "url",
          "source": "/document/metadata_storage_path"
        }
      ],
      "outputs": [
        {
          "name": "enrichedPages",
          "targetName": "enrichedPages"
        }
      ]
    }
  ]
```