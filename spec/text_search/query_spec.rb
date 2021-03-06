require 'text_search'

describe TextSearch::Query do
  describe 'with a single term' do
    before do
      @query = TextSearch::Query.new('term')
    end

    it 'has the right query' do
      expect(@query.query).to eq(%w(''term''))
    end

    it 'has the correct sql' do
      expect(@query.to_sql).to eq("to_tsquery('english', '''term'':*')")
    end
  end

  describe 'with multiple terms' do
    before do
      @query = TextSearch::Query.new('term term2 term3')
    end

    it 'has the right query' do
      expect(@query.query).to eq(%w(''term'' ''term2'' ''term3''))
    end

    it 'has the correct sql' do
      expect(@query.to_sql).to eq("to_tsquery('english', '''term'':*') || to_tsquery('english', '''term2'':*') || to_tsquery('english', '''term3'':*')")
    end
  end
end