Project for Finance with Big Data @ Uni Bocconi.  
The two solidity files that are needed are TokenUni.sol and StoreCharity.sol

1. Deploy store StoreCharity.sol with address 1(us)

2. NewUni on StoreCharity.sol with address 2(UNI)
3. NewDonor on StoreCharity.sol with address 3(DONOR) # you can create as many donors as you want

MOVE TO TOKENUNI

4. NewContract on TokenUni.sol deployed by student (uni address2, description, store address) from StoreCharity.sol

5. Uni adress can validate token on TokenUni.sol

Once token has been validated, donors can donate:
6. Donor can donate on TokenUni.sol with specific amount (in ETH) (you can create multiple donors)

7. Student address can choose a TOKEN (all the others will be reverted and money sent back (minus gas fee))

8. Uni address can withdraw the amount to its balance.
