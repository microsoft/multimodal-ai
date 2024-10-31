# Multimodal AI

## Table of Contents

- [Multimodal AI](#multimodal-ai)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [About this project](#about-this-project)
  - [What's included](#whats-included)
  - [High-level architecture](#high-level-architecture)
  - [Azure services required](#azure-services-required)
  - [Deployment](#deployment)
  - [References](#references)
    - [Sample documents](#sample-documents)
  - [Contributing](#contributing)
  - [Trademarks](#trademarks)

## Overview

Welcome to the Multimodal AI project!

The goal of the Multimodal AI project is to provide an enterprise-ready solution for customers looking to infuse Generative AI (Gen AI) into their existing applications, or create brand-new applications, that go beyond processing text-based content only. This project leverages the latest advancements in multimodal AI, to implement generative AI solutions such as Retrieval Augmented Generation (RAG), image classification or video analysis, for content based on text, images, audio and video. For images, the goal is to go beyond traditional Object Character Recognition (OCR) and generate embeddings on the actual image content

## About this project

This project has been created and is maintained by the Strategic Workload Acceleration Team (SWAT) at Microsoft and we aim to provide enterprise-ready GenAI solutions regardless of whether the data is in text, image, audio or video format.

With the rapid development and introduction of new multimodal AI models, such as [GPT-4o](https://openai.com/index/hello-gpt-4o/), customers are realizing the value of implementing GenAI solutions that go beyond simply using text-based documents within their organizations and instead, they are looking for solutions that leverage other media types that are in use within their organizations, for example, categorize a video and find specific scenes or analyse documents with images embedded that include architectural diagrams or flow charts to provide better answers to technical support personnel.

This project aims to provide a GenAI solution that enables customers to interact with their data across various formats—including text, text with images, images, audio, and video using native Azure PaaS services. Through this solution, data can be processed server-side on Azure for activities like chunking, generating images from files, creating embeddings, indexing content, extracting transcripts from videos, and identifying key scenes in videos, among other multimodal AI tasks. This architecture ensures an enterprise-grade, highly scalable solution that can grow with business demands by leveraging Azure's power and scalability, without reliance on client-side processing or local developer workstations.

## What's included
In this initial release, the Multimodal AI project includes:

- A RAG solution using Azure AI Services that allow users to interact with data contained in text and images (for example, charts or diagrams).
- A web client (see [references](#references)) that users can interact with to submit prompts, get results and visualize the citations.
   - Optional authentication via Entra Id.
- Reference implementations in Terraform and Bicep.
- A simple deployment experience, with a minimal set of prerequistes, that can easily be incorporated into CI/CD deployment pipelines.
- Data processing activities (like chunking, generating embeddings, converting documents to images, etc.) are executed server-side on Azure via Azure AI Search (using built-in capabilities as well as using custom skills).
- Usage of AI Search [data sources](https://learn.microsoft.com/en-us/AZURE/search/search-data-sources-gallery) for easier processing and ingestion of documents by simply uploading the documents, images, videos, etc. to Azure Storage (blob).
   - In this release only PDF file types are supported.
- Multimodal embeddings generated by using [AI Search integrated vectorization](https://learn.microsoft.com/en-us/azure/search/vector-search-integrated-vectorization):
   - Images: Azure AI Vision multimodal embeddings skill (in preview): https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-vision-vectorize
   - Text: Azure OpenAI Embedding skill : https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-azure-openai-embedding
- Image generation from PDF files as part of the AI Search indexing process by using an Indexer.
- Usage of Azure AI Search [custom skills](https://learn.microsoft.com/en-us/azure/search/cognitive-search-custom-skill-interface) (for activities like interacting with Azure Document Intelligence).
- Leverage AI Search [knowledge storage](https://learn.microsoft.com/en-us/azure/search/knowledge-store-concept-intro) to persist images generated as part of the indexing process.

Please note that additional capabilities, including support for audio and video content, compatibility with other file types, and the enablement of network security features like virtual networks and private endpoints, are on the roadmap and will be incorporated in future releases.

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
   - Used by AI Search for billing purposes
- Document Intelligence
   - To extract text from documents
- Azure AI Vision (Computer Vision)
   - For generating embeddings of images
- Azure Functions
   - For hosting AI Search custom skills
- Azure App Service
   - For the web application
- Azure Entra Id
   - For authenticating users accesing the web application
- Azure Log Analytics Workspace
- Azure Application Insights
- Storage Account
   - To provide the documents to be indexed
   - To host the knowledgestore storing the created/extracted images

## Deployment

This project is designed to streamline enterprise deployment through CI/CD tooling and pipelines while also allowing easy deployment from developer workstations for evaluation purposes. It can be deployed using either Bicep or Terraform. Please select your preferred deployment solution below:

- [Bicep](/deployment/bicep/readme.md)
- [Terraform](/deployment/terraform/)

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
