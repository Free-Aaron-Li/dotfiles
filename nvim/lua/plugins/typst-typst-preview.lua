return{
  {
    'chomosuke/typst-preview.nvim',
    lazy = false, -- or ft = 'typst'
    version = '0.1.*',
    build = function() 
      require 'typst-preview'.update() 
    end,
    config = function()
      require('typst-preview').setup({
        debug=true,
        dependencies_bin = {
          ['typst-preview'] = "/home/aaron/Software/typst-preview/typst-preview",
          ['websocat'] = "/home/aaron/Software/typst-preview/websocat"
        },
        get_root = function(bufnr_of_typst_buffer)
          return vim.fn.getcwd()
        end,
      })
    end,
  }
}
