module MyLib (runExample, runPipeline, loadModel, ModelPtr) where
import Foreign
import Foreign.C

type ModelPtr = Ptr Model

data Model

foreign import ccall unsafe "load_model" cLoadModel
  :: CString -> IO (Ptr Model)

foreign import ccall unsafe "run_pipeline_simple" cRunPipeline
  :: Ptr Model -> CString -> IO CString

foreign import ccall unsafe "free_cstr" freeCString
  :: CString -> IO ()

-- | Run the default ud pipeline on an input string.
runPipeline :: Ptr Model -> String -> IO String
runPipeline model input = do
  withCString input $ \cInput -> do
    cOutput <- cRunPipeline model cInput
    output <- peekCString cOutput
    freeCString cOutput
    return output

-- | Load a model from a file.
loadModel :: FilePath -> IO (Either String ModelPtr)
loadModel path = do
  withCString path $ \cPath -> do
    model <- cLoadModel cPath
    if model == nullPtr
      then return $ Left $ "Failed to load model from " ++ path
      else return $ Right model

runExample :: IO ()
runExample = do
    -- TODO: Free data (e.g. using withCString)
    let modelName = "models/english-lines-ud-2.5-191206.udpipe"
    mod <- loadModel modelName
    case mod of
      Left msg -> putStrLn msg
      Right mod -> do
        let input = "This is an example"
        ans <- runPipeline mod input
        putStrLn ans
        putStrLn "runExample"

-- TODO: Handle errors in the C++ code (give back error message)
