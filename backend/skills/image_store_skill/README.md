# Sample usage

```json
"skills": [
    {
      "@odata.type": "#Microsoft.Skills.Custom.WebApiSkill",
      "name": "image_store_skill",
      "description": "A custom skill stores base64 encoded images to a blob storage",
      "context": "/document",
      "uri": " https://[host]/api/image_store_skill",
      "httpMethod": "POST",
      "inputs": [
        {
          "name": "images",
          "source": "/document/normalized_images/*"
        },
        {
          "name": "filename",
          "source": "/document/metadata_storage_name"
        }
      ],
      "outputs": [
        {
          "name": "urls",
          "targetName": "urls"
        }
      ]
    }
  ]
```