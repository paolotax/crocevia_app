describe 'Riga' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Riga entity' do
    Riga.entity_description.name.should == 'Riga'
  end
end
