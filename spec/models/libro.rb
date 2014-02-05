describe 'Libro' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Libro entity' do
    Libro.entity_description.name.should == 'Libro'
  end
end
