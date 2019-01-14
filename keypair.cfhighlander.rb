CfhighlanderTemplate do

  Name 'keypair'

  Parameters do
    ComponentParam 'KeyPairName'
    ComponentParam 'SSMParameterPath' 
  end

  LambdaFunctions 'keypair_custom_resources'

end