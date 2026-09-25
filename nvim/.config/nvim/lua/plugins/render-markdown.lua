return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = function(_, opts)
      -- LazyVim's markdown extra strips the plugin's defaults: no heading icons
      -- (so '#' stays visible), no sign column icons, no checkboxes and
      -- block-width code. Drop those overrides so render-markdown's own apply.
      opts.heading = nil
      opts.code = nil
      opts.checkbox = nil
    end,
  },
}
