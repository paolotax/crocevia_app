describe 'Appunto' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Appunto entity' do
    Appunto.entity_description.name.should == 'Appunto'
  end
end
