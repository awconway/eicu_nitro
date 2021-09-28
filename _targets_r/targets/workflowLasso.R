tar_target(workflowLasso, {
  workflow()|>
      add_recipe(recLasso)|>
      add_model(specLasso)
})
