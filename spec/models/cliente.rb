describe 'Cliente' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Cliente entity' do
    Cliente.entity_description.name.should == 'Cliente'
  end
end
