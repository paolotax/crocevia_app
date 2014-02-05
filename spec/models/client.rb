describe 'Client' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Client entity' do
    Client.entity_description.name.should == 'Client'
  end
end
