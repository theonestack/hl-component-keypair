CloudFormation do

  Resource('KeyPair') do
    Type 'Custom::KeyPair'
    Property 'ServiceToken',FnGetAtt('KeyPairCR','Arn')
    Property 'Region', Ref('AWS::Region')
    Property 'KeyPairName', Ref('KeyPairName')
    Property 'SSMParameterPath', Ref('SSMParameterPath')
  end

  Output('KeyPair'){ Value(Ref('KeyPair'))}

end