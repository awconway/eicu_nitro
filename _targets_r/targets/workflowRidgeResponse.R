tar_target(workflowRidgeResponse, {
  workflow()|>
      add_recipe(recRidgeResponse)|>
      add_model(specRidgeResponse)
})
