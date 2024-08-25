using './multimodal-ai.bicep'

param prefix = 'mmai'
param location = 'eastus'
param aiVisionlocation = 'eastus'
param docIntelLocation = 'eastus'
param tags = {}

param aoaiDeployments = [
  {
    name: 'text-embedding-3-large'    
    model: {
      format: 'OpenAI'      
      version: '1'
    }
    sku: {
      capacity: 30      
    }
  }
  {
    name: 'gpt-4o'    
    model: {
      format: 'OpenAI'      
      version: '2024-05-13'
    }
    sku: {
      capacity: 20      
    }    
  }
  {
    name: 'gpt-35-turbo'
    model: {
      format: 'OpenAI'      
      version: '0613'
    }
    sku: {
      capacity: 60      
    }    
  }
]
