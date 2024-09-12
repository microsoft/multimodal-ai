# Multimodal AI

## Overview

Welcome to the Multimodal AI project!

The Multimodal AI project aims to build on the work of other [Open Source projects at Microsoft](https://github.com/Azure-Samples/azure-search-openai-demo) and deliver an enterprise-ready solution for customers that require Generative AI (Gen AI) solutions that go beyond text-based content by implementing Gen AI solutions (such as Retrieval Augmented Generation or RAG or image classification) based on text, images and audio content. For images, the goal is to go beyond traditional Object Character Recognition (OCR) and generate embeddings on the actual image contents (colors, objects, locations, coordinates, etc).

## What's included

This project build upon the existing [ChatGPT-like app with your data using Azure OpenAI and Azure AI Search](https://github.com/Azure-Samples/azure-search-openai-demo) Microsoft Open Source project, but instead of doing all the Azure services configuration and document processing activities client side via Python scripts (for example, index creation in AI Search or generate images and embeddings from PDF files), this project enhances that experience by making it enterprise-ready with the following features:

- It focuses in the multimodal Gen AI scenario, in order to generate embeddings based on text- and images: https://github.com/Azure-Samples/azure-search-openai-demo/blob/main/docs/gpt4v.md
- Simplify prerequisites and deployment experience by using a minimal set of requirements.
- Enterprise-level deployment experience via Terraform (given that most enterprise customers use Terraform for their enterprise CI/CD and IaC practices) and Bicep.
- Move the file processing activities (like chunking, generating embeddings, converting documents to images, etc.) from client-side python scripts to a server-side platform on Azure in Azure AI Search by using the integrated vectorization capabilities (in preview for images).
- Multimodal embeddings will be generated using [AI Search integrated vectorization](https://learn.microsoft.com/en-us/azure/search/vector-search-integrated-vectorization):
   - Images: Azure AI Vision multimodal embeddings skill (in preview): https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-vision-vectorize
   - Text: Azure OpenAI Embedding skill : https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-azure-openai-embedding
- Use AI Search [data sources](https://learn.microsoft.com/en-us/AZURE/search/search-data-sources-gallery) for easier processing of documents (without having to use local Python scripts from a developer computer to index additional content)
- Generate images from PDF files as part of the AI Search indexing process via an Indexer.
- Usage of Azure AI Search [custom skills](https://learn.microsoft.com/en-us/azure/search/cognitive-search-custom-skill-interface) to interact with Azure Document Intelligence and persisting images from PDF files.
- Leverage AI Search [knowledge storage](https://learn.microsoft.com/en-us/azure/search/knowledge-store-concept-intro) to persist images generated as part of the indexing process.
- Extend the existing web application to support JPG images (as that is the extension that AI Search generates them)

## High-level architecture

The following picture depicts the high-level architecture of the Multimodal AI Project:

![High-level architecture](docs/images/high-level-architecture.png)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
