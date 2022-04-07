{- |
A very simple binding for udpipe.

Example usage:

> import UDPipe
>
> main = do
>   let sentence = "The quick brown fox jumps over the lazy dog."
>   let modelFile = "models/english-lines-ud-2.5-191206.udpipe"
>   model' <- loadModel modelFile
>   let model = case model' of
>                 Left err -> error err
>                 Right m -> m
>   result <- runPipe model sentence
>   putStrLn result


-}
module UDPipe (runExample, runPipeline, loadModel, Model) where
import Foreign
    ( Ptr, FunPtr, nullPtr, newForeignPtr, withForeignPtr, ForeignPtr, Storable (peek) )
import Foreign.C ( peekCString, withCString, CString, CBool )
import Control.Exception (bracket, mask_)
import Foreign.Marshal.Alloc (alloca)

-- | A loaded udpipe model.
newtype Model = Model (ForeignPtr ModelRep)

type ModelPtr = Ptr ModelRep

data ModelRep

foreign import ccall unsafe "load_model" cLoadModel
  :: CString -> IO ModelPtr

foreign import ccall unsafe "run_pipeline_simple" cRunPipeline
  :: ModelPtr -> CString -> Ptr CBool -> IO CString

foreign import ccall unsafe "free_cstr" freeCString
  :: CString -> IO ()

foreign import ccall unsafe "&free_model" freeModel
  :: FunPtr (ModelPtr -> IO ())

-- | Run the default ud pipeline on an input string.
runPipeline :: Model -> String -> IO (Either String String)
runPipeline (Model fmodel) input = do
  withCString input $ \cInput ->
    alloca $ \successPtr ->
      withForeignPtr fmodel $ \model ->
        bracket (cRunPipeline model cInput successPtr) freeCString $ \ x -> do
          success <- peek successPtr
          str <- peekCString x
          return $ if success == 1 then Right str else Left str

-- | Load a model from a file.
loadModel :: FilePath -> IO (Either String Model)
loadModel path = do
  withCString path $ \cPath -> mask_ $ do
    -- mask_ is needed to avoid leaking the pointer in case an async exception
    -- occurs between allocation and wrapping it in a foreign pointer.
    model <- cLoadModel cPath
    if model == nullPtr
      then return $ Left $ "Failed to load model from " ++ path
      else do
        fmodel <- newForeignPtr freeModel model
        return $ Right $ Model fmodel

-- | An example of how to use the library.
runExample :: IO ()
runExample = do
    let modelName = "models/english-lines-ud-2.5-191206.udpipe"
    mod <- loadModel modelName
    case mod of
      Left msg -> putStrLn msg
      Right mod -> do
        let input = "This is an example"
        ans <- runPipeline mod input
        putStrLn $ either ("Error running pipeline: "++) id ans

{- TODO: 
 - * Handle errors in the C++ code (give back error message)
 -} 