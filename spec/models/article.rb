describe 'Article' do

  before do
    include CDQ
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Article entity' do
    Article.entity_description.name.should == 'Article'
  end
end
