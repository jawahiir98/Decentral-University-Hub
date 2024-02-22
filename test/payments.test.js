const Tokens = artifacts.require('Tokens')
const Payments = artifacts.require('Payments')

require('chai')
.use(require('chai-as-promised'))
.should()

contract('Payments', ([owner, student,  student1 ,admin, shopowner]) => {
    let tokens;
    let payments;

    function Convert(number) {
        return web3.utils.toWei(number, 'ether')
    } 

    before(async () => {
        // load Contracts
        tokens = await Tokens.new();
        payments = await Payments.new(tokens.address);
       

        // Set up roles by default ... 
        await payments.setRole(1, admin, {from: owner})
        await payments.setRole(0, student, {from: admin})
        await payments.setRole(0, student1, {from: admin})
        await payments.setRole(3, shopowner, {from: admin})

        // Send student 100 tokens for testing purposes. . . .
        await payments.transfer(student, Convert('100'), {from: owner})
    });
    
    
    describe('Token deployment', async () => {
        it('Name matched', async() =>{
            const name = await tokens.name()
            assert.equal(name, 'AiubVerse')
        })
        it('Symbol matched', async() => {
            const symbol = await tokens.symbol()
            assert.equal(symbol, 'BDT')
        })
    })

    describe('RBAC for payments', async() =>{
        it('User roles found', async() =>{

            // The type of users that should be prevented to use the functions.
            await payments.setRole({from: student}).should.be.rejected
            await payments.setRole({from: shopowner}).should.be.rejected

            // Role check for the admin address
            let res = await payments.hasRole(admin)        
            assert.equal(res.toString(), 'true')    
            res = await payments.queryRole(admin)
            assert.equal(res.toString(), 'Admin')

            // Role check for the sutdent address
            res = await payments.hasRole(student)        
            assert.equal(res.toString(), 'true')    
            res = await payments.queryRole(student)
            assert.equal(res.toString(), 'Student')
            
            // Role check for shopowner address
            res = await payments.hasRole(shopowner)        
            assert.equal(res.toString(), 'true')    
            res = await payments.queryRole(shopowner)
            assert.equal(res.toString(), 'Shop owner')
        })


        describe('Payments', async () => {
            it('Payment functionalities', async() => {
                // Set up roles
                await payments.setRole(3, shopowner, {from: owner})
                await payments.setRole(0, student, {from: owner})
                await payments.setRole(1, admin, {from: owner})
                // Check if transfer function is working
                let result = await payments.balanceOf(student)
                assert.equal(result.toString(), Convert('100'), "student has 100 tokens")
                
                // Pay At Shop Function Check
                // Student has 100 tokens. He paid 10 tokens to the shopowner. Remaining =>
                // Shop owner: 10 
                // Student : 90.
                await payments.payShop(shopowner, Convert('10'), {from: student})
                result = await payments.balanceOf(shopowner);
                assert.equal(result.toString(), Convert('10'))
                
                result = await payments.balanceOf(student);
                assert.equal(result.toString(), Convert('90'))
                
                // Pay at Library Function Check
                // Student had 90. After transfer student: 80, shopowner: 20
                await payments.payLibrary(shopowner, Convert('10'), {from: student})
                result = await payments.balanceOf(shopowner);
                assert.equal(result.toString(), Convert('20'))
                
                result = await payments.balanceOf(student);
                assert.equal(result.toString(), Convert('80'))

                // Inter-user Transactions
                // Student had 80. After transfer student: 80 student1: 10
                await payments.transferToken(student1, Convert('10'), {from: student})
                result = await payments.balanceOf(student1)
                assert.equal(result.toString(), Convert('10'))

                result = await payments.balanceOf(student)
                assert.equal(result.toString(), Convert('70'))
            })
        })
    })
    

    // describe('Yield Farming', async() => { 
    //     it('rewards tokens for staking', async() => {
    //         //check investor balance
    //         let result
    //         result = await tether.balanceOf(customer);
    //         // should equal "100" (the amount they were sent from deployment)
    //         assert.equal(result.toString(), tokens('100'), 'customer wallet balance before staking')

    //         // Check staking for customer
    //         // send out the approval (send to decentralBank, from the customer)
    //         await tether.approve(decentralBank.address, tokens('100'), {from: customer})
    //         // after ^ has been approved, we can deposit tokens to the decentralBank from our customer 
    //         await decentralBank.depositTokens(tokens('100'), {from: customer})

    //         // Check updated balance of customer 
    //         result = await tether.balanceOf(customer)
    //         assert.equal(result.toString(), tokens('0'), 'customer wallet balance after staking 100 tokens')

    //         // Check updated balance of bank 
    //         result = await tether.balanceOf(decentralBank.address);
    //         assert.equal(result.toString(), tokens('100'), 'decentral bank wallet balance after staking from customer')

    //         // isStaking balance
    //         result = await decentralBank.isStaking(customer);
    //         assert.equal(result.toString(), 'true', 'customer is staking status after staking')


    //         // Issue Tokens 
    //         await decentralBank.issueTokens({from: owner})

    //         // check that only the owner can issue tokens 
    //         await decentralBank.issueTokens({from: customer}).should.be.rejected;

    //         // Check that we can unstake tokens
    //         await decentralBank.untakeTokens({from: customer})

    //         //! after unstaking there should be 100 tokens retured to customer
    //         result = await tether.balanceOf(customer)
    //         assert.equal(result.toString(), tokens('100'), 'customer wallet balance after unstaking 100 tokens')

    //         // Check updated balance of bank 
    //         result = await tether.balanceOf(decentralBank.address);
    //         assert.equal(result.toString(), tokens('0'), 'decentral bank wallet balance after unstaking from customer')

    //         // isStaking should be false 
    //         result = await decentralBank.isStaking(customer);
    //         assert.equal(result.toString(), 'false', 'customer is NOT staking anymore')
    //     })
    // });

   
})