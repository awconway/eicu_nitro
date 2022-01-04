tar_target(workflowLassoResponse, {
  workflow()|>
      add_recipe(recLassoResponse)|>
      add_model(specLassoResponse)
})
