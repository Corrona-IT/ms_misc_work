render2 <- function()
{
  # Render HTML output
  render(myfile, 
         output_format = "html_document",
         output_dir = myoutdir)
  # Render Word output
  render(myfile, 
         output_format = "word_document",
         output_dir = myoutdir)
}