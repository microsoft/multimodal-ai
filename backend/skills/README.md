# Sample usage

```json
{
  "@odata.context": "https://gptkb-7zsanbip5xnfk.search.windows.net/$metadata#skillsets/$entity",
  "@odata.etag": "\"0x8DCC386E11C36F9\"",
  "name": "gptkbindex-skillset",
  "description": "Skillset to chunk documents and generate embeddings",
  "skills": [
    {
      "@odata.type": "#Microsoft.Skills.Vision.VectorizeSkill",
      "name": "image-embedding-skill",
      "description": "Skill to generate embeddings for image via Azure AI Vision",
      "context": "/document/normalized_images/*",
      "modelVersion": "2023-04-15",
      "inputs": [
        {
          "name": "image",
          "source": "/document/normalized_images/*"
        }
      ],
      "outputs": [
        {
          "name": "vector",
          "targetName": "imageEmbedding"
        }
      ]
    },
    {
      "@odata.type": "#Microsoft.Skills.Custom.WebApiSkill",
      "name": "pdf_text_image_merge_skill",
      "description": "A custom skill that combines image embeddings with corresponding PDF pages and stores the images",
      "context": "/document",
      "uri": "https://4f46-88-152-244-248.ngrok-free.app/api/pdf_text_image_merge_skill",
      "httpMethod": "POST",
      "timeout": "PT1M",
      "batchSize": 4,
      "degreeOfParallelism": 4,
      "authResourceId": null,
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
      ],
      "httpHeaders": {},
      "authIdentity": null
    },
    {
      "@odata.type": "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill",
      "name": "#3",
      "description": "Skill to generate embeddings via Azure OpenAI",
      "context": "/document/enrichedPages/*",
      "resourceUri": "https://cog-7zsanbip5xnfk.openai.azure.com",
      "apiKey": null,
      "deploymentId": "embedding",
      "dimensions": 1536,
      "modelName": "text-embedding-ada-002",
      "inputs": [
        {
          "name": "text",
          "source": "/document/enrichedPages/*/content"
        }
      ],
      "outputs": [
        {
          "name": "embedding",
          "targetName": "embedding"
        }
      ],
      "authIdentity": null
    },
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
  ],
  "cognitiveServices": {
    "@odata.type": "#Microsoft.Azure.Search.CognitiveServicesByKey",
    "description": null,
    "key": null
  },
  "knowledgeStore": null,
  "indexProjections": {
    "selectors": [
      {
        "targetIndexName": "gptkbindex",
        "parentKeyFieldName": "parent_id",
        "sourceContext": "/document/enrichedPages/*",
        "mappings": [
          {
            "name": "content",
            "source": "/document/enrichedPages/*/content",
            "sourceContext": null,
            "inputs": []
          },
          {
            "name": "embedding",
            "source": "/document/enrichedPages/*/embedding",
            "sourceContext": null,
            "inputs": []
          },
          {
            "name": "sourcepage",
            "source": "/document/enrichedPages/*/sourcepage",
            "sourceContext": null,
            "inputs": []
          },
          {
            "name": "sourcefile",
            "source": "/document/enrichedPages/*/sourcefile",
            "sourceContext": null,
            "inputs": []
          },
          {
            "name": "storageUrl",
            "source": "/document/enrichedPages/*/storageUrl",
            "sourceContext": null,
            "inputs": []
          },
          {
            "name": "imageEmbedding",
            "source": "/document/enrichedPages/*/imageEmbedding",
            "sourceContext": null,
            "inputs": []
          }
        ]
      }
    ],
    "parameters": {
      "projectionMode": "skipIndexingParentDocuments"
    }
  },
  "encryptionKey": null
}
```