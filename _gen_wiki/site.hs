--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Data.Typeable

-- latex
import           Text.Pandoc.Options

import Hakyll
--------------------------------------------------------------------------------

-- so that it exports to the correct folder
config::Configuration
config = defaultConfiguration {
  destinationDirectory = "../docs/wiki/"
}

main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "items/*" $ do
        route $ setExtension "html"
        compile $ pandocMathCompiler
            >>= loadAndApplyTemplate "templates/item.html"    iCtx
            >>= loadAndApplyTemplate "templates/default.html" iCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            items <- recentFirst =<< loadAll "items/*"
            let indexCtx =
                    listField "items" iCtx (return items) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
iCtx::Context String
iCtx =
    defaultContext

pandocMathCompiler =
    let mathExtensions    = extensionsFromList [Ext_tex_math_dollars, Ext_tex_math_double_backslash, Ext_latex_macros]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions     = defaultExtensions <> mathExtensions
        writerOptions     = defaultHakyllWriterOptions {
                              writerExtensions = newExtensions,
                              writerHTMLMathMethod = MathJax ""
                            }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions
