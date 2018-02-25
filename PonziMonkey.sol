pragma solidity ^0.4.18;

contract PonziMonkey {
    uint256 growthRate;

    address[] monkeys;
    uint[] bananas;
    uint256 toFedMonkeyId;

    address owner;
    uint256 feeRate;
    
    // This generates a public event on the blockchain that will notify the monkeys
    event FeedReport(address indexed to, uint256 value);
    event Fee(address indexed to, uint256 value);

    /* Constructor */
    function PonziMonkey(uint8 _growthRate, uint8 _feeRate) public {
        // Both args are rates
        require(0 <= _growthRate);
        require(100 > _growthRate);
        require(0 <= _feeRate);
        require(100 > _feeRate);

        growthRate = _growthRate;
        toFedMonkeyId = 0;

        owner = msg.sender;
        feeRate = _feeRate;
    }
    
    function enterTheGame() public payable {
        // Register a new monkey
        _register(msg.sender, msg.value)
        
        // Collect fees to cover maintenance expenses
        _collectFees(msg.value)
        
        // Feed previous monkeys
        _feed();
    }

    function _register(address monkey, uint256 banana) internal {
        // Do not process empty bunch of bananas!
        require(banana > 0);

        // Compute expected banana based on growth rate
        uint256 superBanana = banana * (100 + growthRate) / 100;

        // Store this new monkey as the last participant in ponzi scheme
        monkeys.push(monkey);
        bananas.push(superBanana);
    }
    
    function _collectFees(uint256 banana) internal {
        // Compute fees based on transaction banana value
        uint256 fees = banana * feeRate / 100;

        // Transfer the fees to the owner account
        owner.transfer(fees);

        // Emit an event to keep track of how many fees were collected
        Cost(owner, fees);     
    }

    function _feed() internal {
        // Feed them 'til you can't anymore
        while(this.balance > 0)
        {
            // How many bananas the current monkey is expecting?
            uint256 banana = bananas[toFedMonkeyId];

            // Check wether we have enough, or give it all
            if (banana > this.balance) {
                banana = this.balance;
            }

            // Feed the little chimp
            monkeys[toFedMonkeyId].transfer(banana);

            // Let other know your job is done
            FeedReport(monkeys[toFedMonkeyId], banana);

            // If the job is done, let's go to the next monkey
            bananas[toFedMonkeyId] -= banana;
            if (bananas[toFedMonkeyId] == 0) {
                toFedMonkeyId += 1;
            }
        }
    }
}