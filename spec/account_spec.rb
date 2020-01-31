require 'account'

describe Account do


  let(:statement) { double :statement }
  subject(:account) { Account.new(transaction, statement) }

  describe '#deposit' do
    
    before(:each) do
      allow(Transaction).to receive(:debit).with(2000.00, "01/01/2020", 2000.00).and_return([date: "01/01/2020", credit: nil, debit: 2000.00, balance: 2000.00])
      allow(statement).to receive(:add).with(transaction.debit(2000.00, "01/01/2020", 2000.00))
    end

    it 'increases the account balance by a given amount' do
    
      account.deposit(2000.00, "01/01/2020")
      expect(account.balance).to eq(2000.00)
    end

    it 'returns a summary of the tranaction' do
      expect(account.deposit(2000.00, "01/01/2020")).to eq([date: "01/01/2020", credit: nil, debit: 2000.00, balance: 2000.00])
    end

    it 'raises an error if the amount is 0 or below' do
      message = "Error: Please enter a positive amount"
      expect { account.deposit(0.00, "01/01/2020") }.to raise_error message
    end

    it 'raises an error if the date is an invalid format' do
      message = "Error: Invalid date, please use format DD/MM/YY"
      expect { account.deposit(1000.00, "2020-01-01") }.to raise_error message
    end
  end

  describe '#withdraw' do
    before(:each) do
      allow(Transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 2000.00, balance: 2000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
      allow(Transaction).to receive(:credit).with(500.00, "01/01/2020", 500.00).and_return([date: "01/01/2020", credit: 500.00, debit: nil, balance: 500.00])
      allow(statement).to receive(:add).with(transaction.credit(500.00, "01/01/2020", 500.00))
    end

    it 'descreases the account balance by a given amount' do
      account.deposit(1000.00, "01/01/2020")
      account.withdraw(500.00, "01/01/2020")
      expect(account.balance).to eq(500.00)
    end

    it 'returns a summary of the tranaction' do
      account.deposit(1000.00, "01/01/2020")
      expect(subject.withdraw(500.00, "01/01/2020")).to eq([date: "01/01/2020", credit: 500.00, debit: nil, balance: 500.00])
    end

    it 'raises an error if the amount is more than the available balance' do
      account.deposit(1000.00, "01/01/2020")
      message = "Error: Can't withdraw more than balance, 1000.00"
      expect { account.withdraw(1500.00, "01/01/2020") }.to raise_error message
    end

    it 'raises an error if the date is an invalid format' do
      account.deposit(1000.00, "01/01/2020")
      message = "Error: Invalid date, please use format DD/MM/YY"
      expect { account.withdraw(1000.00, "2020-01-01") }.to raise_error message
    end
  end

  context 'When a client successfully deposits 1000.00, then despoits 2000.00, then withdraws 500.00' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
      allow(transaction).to receive(:debit).with(2000.00, "01/01/2020", 3000.00).and_return([date: "01/01/2020", credit: nil, debit: 2000.00, balance: 3000.00])
      allow(statement).to receive(:add).with(transaction.debit(2000.00, "01/01/2020", 3000.0))
      allow(transaction).to receive(:credit).with(500.00, "01/01/2020", 2500.00).and_return([date: "01/01/2020", credit: 500.00, debit: nil, balance: 2500.00])
      allow(statement).to receive(:add).with(transaction.credit(500.00, "01/01/2020", 2500.0))
    end
    
    it 'should return a remaining balance of 2500.00' do
      account.deposit(1000.00, "01/01/2020")
      account.deposit(2000.00, "01/01/2020")
      account.withdraw(500.00, "01/01/2020")
      expect(account.balance).to eq(2500.00)
    end

    it 'should not raise any errors' do
      expect { account.deposit(1000.00, "01/01/2020") }.not_to raise_error
      account.deposit(2000.00, "01/01/2020")
      expect { account.withdraw(500.00, "01/01/2020") }.not_to raise_error
    end
  end

  context 'When a client deposits amounts at 0 and below with correct dates' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
    end
    
    it 'should raise an error for the amount fo 0' do
      message = "Error: Please enter a positive amount"
      expect { account.deposit(0.00, "01/01/2020") }.to raise_error message
    end

    it 'should raise an error for the amount of -1000' do
      message = "Error: Please enter a positive amount"
      expect { account.deposit(-1000.00, "01/01/2020") }.to raise_error message
    end
  end

  context 'When a client deposits positive amounts with an incorrect date format' do
    it 'should raise an error asking for a valid date format DD-MM-YY' do
      message = "Error: Invalid date, please use format DD/MM/YY"
      expect { account.deposit(1000.00, "01-01-2020") }.to raise_error message
    end
  end

  context 'When a client deposits a positive amount with a correct date' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 2000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 2000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 2000.00))
    end
    
    it 'should not raise an error and return a formatted debit transaction' do
      expect { account.deposit(1000.00, "01/01/2020") }.not_to raise_error
      expect(account.deposit(1000.00, "01/01/2020")).to eq [date: "01/01/2020", credit: nil, debit: 1000.00, balance: 2000.00]
    end
  end

  context 'When a client withdraws amounts at 0 and below with correct dates' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
      allow(transaction).to receive(:credit).with(1000.00, "01/01/2020", 0.00).and_return([date: "01/01/2020", credit: 1000.00, debit: nil, balance: 0.00])
      allow(statement).to receive(:add).with(transaction.credit(1000.00, "01/01/2020", 0.00))
    end
    
    it 'should raise an error for the amount fo 0' do
      message = "Error: Please enter a positive amount"
      expect { account.withdraw(0.00, "01/01/2020") }.to raise_error message
    end

    it 'should raise an error for the amount of -1000' do
      message = "Error: Please enter a positive amount"
      expect { account.withdraw(-1000.00, "01/01/2020") }.to raise_error message
    end
  end

  context 'When a client withdraws an amount more than their balance with a correct date format' do
    it 'should raise an error saying they can not withdraw more than their balance' do
      message = "Error: Can't withdraw more than balance, 0.00"
      expect { account.withdraw(1000.00, "01-01-2020") }.to raise_error message
    end
  end

  context 'When a client withdraws an amount less than their balance with an incorrect date format' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
    end
    
    it 'should raise an error asking for a valid date format DD-MM-YY' do
      account.deposit(1000.00, "01/01/2020")
      message = "Error: Invalid date, please use format DD/MM/YY"
      expect { account.withdraw(1000.00, "01-01-2020") }.to raise_error message
    end
  end

  context 'When a client withdraws an amount less than the balance with a correct date' do
    before(:each) do
      allow(transaction).to receive(:debit).with(1000.00, "01/01/2020", 1000.00).and_return([date: "01/01/2020", credit: nil, debit: 1000.00, balance: 1000.00])
      allow(statement).to receive(:add).with(transaction.debit(1000.00, "01/01/2020", 1000.00))
      allow(transaction).to receive(:credit).with(250.00, "01/01/2020", 750.00).and_return([date: "01/01/2020", credit: 250.00, debit: nil, balance: 750.00])
      allow(statement).to receive(:add).with(transaction.credit(250.00, "01/01/2020", 750.00))
      allow(transaction).to receive(:credit).with(250.00, "01/01/2020", 500.00).and_return([date: "01/01/2020", credit: 250.00, debit: nil, balance: 500.00])
      allow(statement).to receive(:add).with(transaction.credit(250.00, "01/01/2020", 500.00))
    end
    
    it 'should not raise an error and return a formatted credit transaction' do
      account.deposit(1000.00, "01/01/2020") 
      expect { account.withdraw(250.00, "01/01/2020") }.not_to raise_error
      expect(account.withdraw(250.00, "01/01/2020")).to eq [date: "01/01/2020", credit: 250.00, debit: nil, balance: 500.00]
    end
  end
end
