module rwa::rwa_platform {

    use std::error;
    use std::event;
    use std::signer;
    use std::string;
    use std::vector;
    use sui::object::{Self, UID};
    use sui::coin::{Self, House};


    /// Struct to represent a real-world asset (RWA)
    struct Rwa has copy, drop, store {
        id: UID,
        name: vector<u8>,
        latitude: f64,
        longitude: f64,
        description: vector<u8>, 
        altitude: f64,           
        timestamp: u64,
        owner: address,          
        area: f64,               
        value: u64,
        tokenValue: u64,
        tokenNb: u64,             
    }

    /// Struct to represent a collateral deposit
    struct Collateral has copy, drop, store {
        owner: address,
        asset: Coin::Coin,
        amount: u64,
    }

    /// Event to log responses
    struct ResponseEvent has copy, drop, store {
        request_id: vector<u8>,
        character: u64,
        response: vector<u8>,
        err: vector<u8>
    }

    /// Initialize a new RWA
    public fun create_rwa(
        owner: &signer,
        name: vector<u8>,
        latitude: f64,
        longitude: f64,
        description: vector<u8>,
        altitude: f64,
        timestamp: u64,
        area: f64,               
        value: u64,
        tokenNb: u64              
    ): Rwa {
        Rwa {
            id: object::new<Rwa>(owner),
            name,
            latitude,
            longitude,
            description,
            altitude,
            timestamp,
            owner: signer::address_of(owner), 
            area,                             
            value, 
            tokenValue: value/tokenNb,
            tokenNb                    
        }
    }

    /// Function to deposit assets as collateral
    public fun deposit_collateral(
        account: &signer,
        asset: Coin::Coin,
        amount: u64
    ): Collateral {
        let owner = signer::address_of(account);
        Collateral {
            owner,
            asset,
            amount,
        }
    }

    /// Function to send a mint request
    public fun send_mint_request(
        rwa: &mut Rwa,
        amount_of_tokens_to_mint: u64
    ) {
        let request_id = vector::empty<u8>();
        event::emit<ResponseEvent>(ResponseEvent {
            request_id,
            character: 1,
            response: vector::empty<u8>(),
            err: vector::empty<u8>()
        });
    }

    /// Function to send a redeem request
    public fun send_redeem_request(
        rwa: &mut Rwa,
        amount_rwa: u64
    ) {
        // Emit an event for the redeem request
        let request_id = vector::empty<u8>();
        event::emit<ResponseEvent>(ResponseEvent {
            request_id,
            character: 2,
            response: vector::empty<u8>(),
            err: vector::empty<u8>()
        });
    }

    /// Function to fulfill a request
    public fun fulfill_request(
        rwa: &mut Rwa,
        request_id: vector<u8>,
        response: vector<u8>,
        err: vector<u8>
    ) {
        // Emit ResponseEvent
        event::emit<ResponseEvent>(ResponseEvent {
            request_id,
            character: 0,
            response,
            err
        });
    }

    /// Function to withdraw funds
    public fun withdraw(rwa: &mut Rwa,col: &mut Collateral, user: address) {
        // Check if the user is the owner of the RWA
        if (col.owner != user) {
            // Emit an error event if the user is not the owner
            let request_id = vector::empty<u8>();
            event::emit<ResponseEvent>(ResponseEvent {
                request_id,
                character: 3,
                response: vector::empty<u8>(),
                err: string::utf8(b"User is not the owner of the Collateral")
            });
            return;
        }

        // Logic to withdraw funds
        // For example, reduce the value of the RWA and perform other necessary operations
        tranfer::transfer(account::from_address(user), col.asset, col.amount);
        col.drop();

        // Emit a success event
        let request_id = vector::empty<u8>();
        event::emit<ResponseEvent>(ResponseEvent {
            request_id,
            character: 3,
            response: string::utf8(b"Funds withdrawn successfully"),
            err: vector::empty<u8>()
        });
    }


    /// Function to get the portfolio balance
    public fun get_portfolio_balance(rwa: &Rwa, col:&Collateral): (u64,u64) {
        (rwa.value,col.amount)
    }

    /// Function to get the RWA price
    public fun get_rwa_tokenValue(rwa: &Rwa): u64 {
        rwa.tokenValue
    }

    /// Function to get the USD value of RWA
    public fun get_usd_value_of_rwa(rwa: &Rwa, rwa_amount: u64): u64 {
        rwa.amount
    }

    /// Function to get a request by ID
    public fun get_request(rwa: &Rwa, request_id: vector<u8>): ResponseEvent {
        ResponseEvent {
            amount_of_token: 0,
            requester: 0x0,
            mint_or_redeem: 0
        }
    }

}