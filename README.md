# Multimodal AI

## Table of Contents

- [Overview](#overview)
- [Deployment](#deployment)
- [About this project](#whats-included)
- [High-level architecture](#high-level-architecture)
- [Azure services required](#azure-services-required)
- [References](#references)
- [Contributing](#contributing)
- [Trademarks](#trademarks)

## Overview

Welcome to the Multimodal AI project!

The Multimodal AI project aims deliver an enterprise-ready solution for customers that require Generative AI (Gen AI) solutions that go beyond text-based content by leveraging the latests advancements in multimodal Artificial intelligence models to implement generative AI solutions such as Retrieval Augmented Generation (RAG), image classification or video analysis, for content based based on text, images, audio and video.

For images, the goal is to go beyond traditional Object Character Recognition (OCR) and generate embeddings on the actual image contents (colors, objects, locations, coordinates, etc).

## Deployment

This project has been implemented to facilitate its deployment for enterprises by using CI/CD tooling and pipelines, as well as make it simple to deploy from developer workstations for evaluation purposes and it can deployed via Bicep or Terraform. Please select the option below of your preferred deployment solution:

- [Bicep](/deployment/bicep/readme.md)
- [Terraform](/deployment/terraform/)

## About this project

This project aims to provide enterprise-ready multimodal Generative AI (GenAI) solutions in customer's environments with their own data. The goal is to provide GenAI solutions independently if the data is in text, images, audio or video format.

With the rapid development and introduction of new multimodal AI models, such as [GPT-4o](https://openai.com/index/hello-gpt-4o/), customers are realizing the value of implementing GenAI solutions that go beyond simply using text-based documents within their organizations and instead, they are looking for solutions that leverage other media types that are in use within their organizations, for example, categorize a video and find specific scenes or analyse documents with images embedded that include architectural diagrams or flow charts to provide better answers to technical support personnel.

This project provides a solution that allows customers to bring their data independently of the format (i.e. can be text, text with images, images, audio or video) and via native Azure PaaS services, process the data (for example, perform chunking, generate images from files, generate embeddings, index content, etc) to deliver Generative AI solutions, such as RAG, independently of the data format as well as ensuring all processing activities are performed server-side on Azure (i.e. no processing is done client-side for example via scripting). This provides a enterprise-grade highly-scalable solution that you can grow and scale as your needs demand thanks to the power and capacity of the Azure platform without having to rely on local processing on developer workstations. 

The scope of this Multimodal AI project is:

- Focused in multimodal Gen AI scenarios instead of traditional AI solutions based on text-only  content.
- Make deployment experience as simple as possible by requiring a minimal set of prerequistes.
- Enterprise-level deployment experience via Terraform and Bicep, for easy incorporation into CI/CD deployment pipelines.
- Data processing activities (like chunking, generating embeddings, converting documents to images, etc.) are executed server-side on Azure via Azure AI Search (using built-in capabilities as well as using custom skills).
- Use AI Search [data sources](https://learn.microsoft.com/en-us/AZURE/search/search-data-sources-gallery) for easier processing and ingestion of documents by simply uploading the documents, images, videos, etc. to Azure Storage (blob).
- Multimodal embeddings generated by using [AI Search integrated vectorization](https://learn.microsoft.com/en-us/azure/search/vector-search-integrated-vectorization):
   - Images: Azure AI Vision multimodal embeddings skill (in preview): https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-vision-vectorize
   - Text: Azure OpenAI Embedding skill : https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-azure-openai-embedding
- Image generation from PDF files as part of the AI Search indexing process via an Indexer.
- Usage of Azure AI Search [custom skills](https://learn.microsoft.com/en-us/azure/search/cognitive-search-custom-skill-interface) to interact with Azure Document Intelligence and persisting images generated as part of the indexing process.
- Leverage AI Search [knowledge storage](https://learn.microsoft.com/en-us/azure/search/knowledge-store-concept-intro) to persist images generated as part of the indexing process.
- Audio and video content is in the roadmap and will be incorporated shortly.

## High-level architecture

The following picture depicts the high-level architecture of the Multimodal AI Project:

![High-level architecture](docs/images/high-level-architecture.png)

## Azure services required

As the architectural diagram in the previous depicts, this project deploys and configures the following Azure resources:

- Azure Open AI with the following models
   - GPT-4o
   - text-embedding-ada-002
- Azure AI Search with the following features configured
   - Data sources
   - Indexes
   - Built-in skills
   - Custom skills
   - Indexer
   - Knowledge store
- Azure AI Services multi-service account
   - Used by AI Search for integrated vectorization of images
- Document Intelligence
   - To extract text from documents
- Azure AI Vision
   - For generating embeddings of images
- Azure Functions
   - For AI Search custom skills
- Azure App Service
   - For the web application
- Azure Log Analytics Workspace
- Azure Application Insights
- Storage Account
   - To provide the documents to be indexed

## References

This project leverages the [ChatGPT-like app with your data using Azure OpenAI and Azure AI Search](https://github.com/Azure-Samples/azure-search-openai-demo) Open Source project by using its web application used by users to submit prompts and get responses from a Large Language Model (LLM) such as Azure OpenAI GPT4o as well as  some of its Python scripts such as: 

- Logic to parse documents with Document Intelligence.
- Logic to parse documents across pages.
- The backend API.

### Sample documents

If you're evaluating this solution and you would like to use some sample documents with mix of text, tables and images, feel free to use some of the sample documents from these GitHub repositories:

- [Azure Search Sample Data](https://github.com/Azure-Samples/azure-search-sample-data)
- [Azure Search Vector Samples](https://github.com/Azure/azure-search-vector-samples)
- [Azure Search OpenAI Demo](https://github.com/Azure-Samples/azure-search-openai-demo)

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
