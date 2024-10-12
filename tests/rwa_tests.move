#[test_only]
module rwa::test_rwa_tests {
    use std::signer;
    use std::vector;
    use std::string;
    use std::assert;
    use rwa::rwa_platform::{Self, Rwa, Collateral, ResponseEvent};

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_create_rwa() {
        let owner = @0x1;
        let name = vector::utf8(b"Test Asset");
        let latitude = 37.7749;
        let longitude = -122.4194;
        let description = vector::utf8(b"Test Description");
        let altitude = 10.0;
        let timestamp = 1234567890;
        let area = 100.0;
        let value = 1000000;
        let tokenNb = 1000;

        let rwa = rwa_platform::create_rwa(
            &owner,
            name,
            latitude,
            longitude,
            description,
            altitude,
            timestamp,
            area,
            value,
            tokenNb
        );

        assert!(rwa.value == value, 1);
        assert!(rwa.tokenNb == tokenNb, 2);
    }

    #[test]
    fun test_deposit_collateral() {
        let owner = @0x1;
        let asset = Coin::mint(1000);
        let amount = 500;

        let collateral = rwa_platform::deposit_collateral(&owner, asset, amount);

        assert!(collateral.amount == amount, 1);
        assert!(collateral.owner == owner, 2);
    }

    #[test]
    fun test_withdraw() {
        let owner = @0x1;
        let asset = Coin::mint(1000);
        let amount = 500;

        let mut rwa = rwa_platform::create_rwa(
            &owner,
            vector::utf8(b"Test Asset"),
            37.7749,
            -122.4194,
            vector::utf8(b"Test Description"),
            10.0,
            1234567890,
            100.0,
            1000000,
            1000
        );

        let mut collateral = rwa_platform::deposit_collateral(&owner, asset, amount);

        rwa_platform::withdraw(&mut rwa, &mut collateral, owner);

        assert!(collateral.amount == 0, 1);
    }

    #[test]
    fun test_get_portfolio_balance() {
        let owner = @0x1;
        let asset = Coin::mint(1000);
        let amount = 500;

        let rwa = rwa_platform::create_rwa(
            &owner,
            vector::utf8(b"Test Asset"),
            37.7749,
            -122.4194,
            vector::utf8(b"Test Description"),
            10.0,
            1234567890,
            100.0,
            1000000,
            1000
        );

        let collateral = rwa_platform::deposit_collateral(&owner, asset, amount);

        let (rwa_value, collateral_amount) = rwa_platform::get_portfolio_balance(&rwa, &collateral);

        assert!(rwa_value == 1000000, 1);
        assert!(collateral_amount == 500, 2);
    }

    #[test]
    fun test_get_rwa_tokenValue() {
        let owner = @0x1;

        let rwa = rwa_platform::create_rwa(
            &owner,
            vector::utf8(b"Test Asset"),
            37.7749,
            -122.4194,
            vector::utf8(b"Test Description"),
            10.0,
            1234567890,
            100.0,
            1000000,
            1000
        );

        let token_value = rwa_platform::get_rwa_tokenValue(&rwa);

        assert!(token_value == 1000, 1);
    }

    #[test]
    fun test_get_usd_value_of_rwa() {
        let owner = @0x1;

        let rwa = rwa_platform::create_rwa(
            &owner,
            vector::utf8(b"Test Asset"),
            37.7749,
            -122.4194,
            vector::utf8(b"Test Description"),
            10.0,
            1234567890,
            100.0,
            1000000,
            1000
        );

        let usd_value = rwa_platform::get_usd_value_of_rwa(&rwa, 100);

        assert!(usd_value == 100, 1);
    }
}
