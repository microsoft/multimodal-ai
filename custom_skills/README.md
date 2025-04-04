# Sample usage

```json
{
  "@odata.context": "https://[host].search.windows.net/$metadata#skillsets/$entity",
  "name": "my-skillset",
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
    },
    {
      "@odata.type": "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill",
      "name": "#3",
      "description": "Skill to generate embeddings via Azure OpenAI",
      "context": "/document/enrichedPages/*",
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
    }
  ],
  "cognitiveServices": {
    "@odata.type": "#Microsoft.Azure.Search.CognitiveServicesByKey",
    "description": null,
    "key": null
  },
  "knowledgeStore": {
    "storageConnectionString": "ResourceId=/subscriptions/{subscription-ID}/resourceGroups/{resource-group-name}/providers/Microsoft.Storage/storageAccounts/storage-account-name};",
    "projections": [
      {
        "tables": [],
        "objects": [],
        "files": [
          {
            "storageContainer": "images",
            "source": "/document/normalized_images/*"
          }
        ]
      }
    ],
    "parameters": {
      "synthesizeGeneratedKeyName": true
    }
  },
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
  }
}
```
