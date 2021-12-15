# Welcome to UNICASH!
This guide will make sure you will be able to follow the flow of our infrastructure in a logical and coherent manner. 
We will deploy our contracts in [Remix - Ethereum IDE](https://remix.ethereum.org/) in our local machine, so please upload **StoreCharity.sol** and **TokenUni.sol** to a new `Workspace`. Once opened, they should look like these: ![image](https://user-images.githubusercontent.com/51834820/146237169-822869b0-ca2f-40d6-9b02-058747007cf5.png)
 and ![image](https://user-images.githubusercontent.com/51834820/146237192-d2ec9c4f-0021-4001-9482-e084b6316951.png).
 
## Compile!
Go to the `Compiler` ![image](https://user-images.githubusercontent.com/51834820/146237629-3381035c-ea01-428a-8e3f-806db2a6974c.png) and make sure to click on ![image](https://user-images.githubusercontent.com/51834820/146237767-e73a8046-ce10-4d5f-ad74-19698fa01fb3.png)
 and ![image](https://user-images.githubusercontent.com/51834820/146237794-79aae94f-c52f-45a0-b249-8f095d0b7f36.png) by repeating the process for each file. We also suggest to tick the `Auto compile` and `Hide warnings` options. Perhaps you will get some harmless warnings that won't obstacle your deployment, likely because of dependencies inherited from GitHub.

## Deploy!
For the sake of smooth and quick demo, we will deploy our files in `JavaScript VM (London)` or `JavaScript VM (Berlin)` looking like this ![image](https://user-images.githubusercontent.com/51834820/146239980-5f4d82dc-5a23-408a-a4f2-39b2f0ca0921.png), freely provided by Remix. It should be clear that you will not actually interact with the existing blockchain as your operations will stay in the safe environment of your local machine.
Such a virtual machine will provide you with several test accounts:    

![image](https://user-images.githubusercontent.com/51834820/146240132-e23f0fa5-8f39-4496-928b-1d2b3de2c1e0.png)

In this guide, we will use the first address called `address_n_1` as to be us, the UNICASH Company, the second one as to be the Student called `address_n_2`, the addresses from the third onwards as the universities (`address_n_3`, `address_n_4`, ...) and the last addresses as the donors (`address_n_-1`, `address_n_-2`, ...).


### 1. StoreCharity.sol
Only UNICASH Company, universities and donors interact with the Big Contract, namely **StoreCharity** which acts as a database where all informations about contracts, donations, authorizations are recorded. The first step is to set yourself on `address_n_1` in the virtual machine and deploy ![image](https://user-images.githubusercontent.com/51834820/146244176-23e795c3-eaf9-4f59-9f92-ac1f981769a4.png) for the first and last time using the ![image](https://user-images.githubusercontent.com/51834820/146241947-011c437e-63ac-4e99-9c59-0c395825077f.png) button. From this moment on, only **minting** will be possible on StoreCharity. A contract should have appeared in the list of recorded transactions: click on the name of ![image](https://user-images.githubusercontent.com/51834820/146242320-3d1777af-9fc0-449e-a887-12ef23d9b0ae.png) to start interacting with its public functions!


### 2. Register universities and donors
You will see a lot of available functions to be called, as the majority of them are **external** so to interact with **TokenUni.sol**. However, universities will only need `NewUni` function and donors only `NewDonor` function. 

In order to register as a university, switch to `address_n_3` (or `address_n_4`, ...) and feed in your name, e.g. "Bocconi", in ![image](https://user-images.githubusercontent.com/51834820/146243190-89cb9a8b-1e9d-47b4-bbbe-6e907f3b737d.png) and press the button. You can do this process as many times you want, using as many accounts you wish, in order to register several universities.

A donor can register analogously, by switching to `address_n_-1` (or `address_n_-2`, ...) and writing his or her name in `NewDonor`, then clicking on ![image](https://user-images.githubusercontent.com/51834820/146243717-e5b29625-b7d6-4172-8288-75cdc31229e8.png).

For this demo, just add two universities using `address_n_3` and `address_n_4` and two donors using `address_n_-1` and `address_n_-2`.


### 3. New token from the student
Now you can leave `StoreCharity` work in the background: move to ![image](https://user-images.githubusercontent.com/51834820/146244451-2f069d9e-4038-497b-9125-4f07a1445317.png) and never look back!

As a student, you own `address_n_2` but no contracts yet. Once you have been accepted to a university program, you can issue a token on the blockchain to get financed: you will need to know the university address and the Big Contract one. The first can be found on the blockchain or the university will provide you with it (in our case, use the stored `address_n_3` and `address_n_4`), for the latter you just need to copy the deployed StoreCharity contract by clicking on the symbol ![image](https://user-images.githubusercontent.com/51834820/146278542-74bd606f-b0e2-4bd3-9455-e65dc574ac25.png) on the right side.

Switching to
 



