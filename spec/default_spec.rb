require 'yaml'

describe 'compiled component keypair' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/keypair.compiled.yaml") }
  
  context "Resource" do

    
    context "KeyPair" do
      let(:resource) { template["Resources"]["KeyPair"] }

      it "is of type Custom::KeyPair" do
          expect(resource["Type"]).to eq("Custom::KeyPair")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["KeyPairCR", "Arn"]})
      end
      
      it "to have property Region" do
          expect(resource["Properties"]["Region"]).to eq({"Ref"=>"AWS::Region"})
      end
      
      it "to have property KeyPairName" do
          expect(resource["Properties"]["KeyPairName"]).to eq({"Ref"=>"KeyPairName"})
      end
      
      it "to have property SSMParameterPath" do
          expect(resource["Properties"]["SSMParameterPath"]).to eq({"Ref"=>"SSMParameterPath"})
      end
      
    end
    
    context "LambdaRoleKeyPairResource" do
      let(:resource) { template["Resources"]["LambdaRoleKeyPairResource"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"cloudwatch-logs", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["arn:aws:logs:*:*:*"]}]}}, {"PolicyName"=>"keypair", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["ec2:CreateKeyPair", "ec2:DeleteKeyPair", "ssm:PutParameter", "ssm:DeleteParameter"], "Resource"=>"*"}]}}, {"PolicyName"=>"lambda", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["lambda:InvokeFunction"], "Resource"=>{"Fn::Sub"=>"arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:${AWS::StackName}-KeyPairCR*"}}]}}])
      end
      
    end
    
    context "KeyPairCR" do
      let(:resource) { template["Resources"]["KeyPairCR"] }

      it "is of type AWS::Lambda::Function" do
          expect(resource["Type"]).to eq("AWS::Lambda::Function")
      end
      
      it "to have property Code" do
        expect(resource["Properties"]["Code"]["S3Bucket"]).to eq("")
        expect(resource["Properties"]["Code"]["S3Key"]).to start_with("/latest/KeyPairCR.keypair.latest.")
      end
      
      it "to have property Environment" do
          expect(resource["Properties"]["Environment"]).to eq({"Variables"=>{}})
      end
      
      it "to have property Handler" do
          expect(resource["Properties"]["Handler"]).to eq("cr_keypair.handler")
      end
      
      it "to have property MemorySize" do
          expect(resource["Properties"]["MemorySize"]).to eq(128)
      end
      
      it "to have property Role" do
          expect(resource["Properties"]["Role"]).to eq({"Fn::GetAtt"=>["LambdaRoleKeyPairResource", "Arn"]})
      end
      
      it "to have property Runtime" do
          expect(resource["Properties"]["Runtime"]).to eq("python3.7")
      end
      
      it "to have property Timeout" do
          expect(resource["Properties"]["Timeout"]).to eq(600)
      end
      
    end

    context 'Resource KeyPairCRVersion' do
    
      let(:resource) { template["Resources"].select {|r| r.start_with?("KeyPairCRVersion") }.keys.first }
      let(:properties) { template["Resources"][resource]["Properties"] }
  
      it 'has property FunctionName' do
        expect(properties["FunctionName"]).to eq({"Ref"=>"KeyPairCR"})
      end
  
      it 'has property CodeSha256' do
        expect(properties["CodeSha256"]).to a_kind_of(String)
      end
  
    end
    
  end

end