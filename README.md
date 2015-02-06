
###Problem
Your User model has a 1-n relation with Cars, which itself has a 1-n relation with FancyUpgrades. For some reason, your API User model represents it's Cars with an attribute car_ids, which contains the ids of the cars that user owns. The same is the case for the fancy upgrades. So this is goddamn wonderful.. that is until you want to display a page containing many users with small snippets of information about their cars and the fancy upgrades those cars have. You're smart and grab the  Users from the client. woooo. But as you iterate, you realize that you're hitting the Garage::Client::Cars endpoint once per user, and the Garage::Client::FancyUpgrades endpoint a metric shitton of times. Shit.  
  
###Solution 
You cook up a slick way to preload each layer of this loading sequence. You already have users, so you iterate over them to get the combination of all of those user's car ids. You batch fetch those and map them into the user under a 'cars' method. wooo. It gets weird when you do this for fancy upgrades, and you quickly realize that this is crazy fucking messy, and you just want a magic solution. Here comes a bulk load solution:  
  
*I havent figured out exactly where one puts this in, so bear with how unreasonable this is*   
  
In the initialization of your API Client, you begin to define certain relations that you want to expose for a client model with the 'bulk loading' layer enabled. For our example, this looks like:  
 
```  
Garage::Client::User.class_eval do 
  bulk_load :cars, Garage::Client::Car, from: car_ids
end

Garage::Client::Car.class_eval do 
  bulk_load :fancy_upgrades, Garage::Client::FancyUpgrade, from: fancy_upgrade_ids
end

...
#In code somewhere - 
my_api_user.cars
>> Array(Garage::Client::Car)
  
```  
So we see that we define the attribute to represent the bulk loading (which becomes the accessor for this association), the Client model that represents the resource endpoint for the association, and a :from parameter which depics which attribute of the current model we are querying this association endpoint with. Additional arguments to this are:  
`attribute`  
 The attribute of the associated model that the values in :from correspond to. This defaults to :id, which works for us because the values in car_ids are the ids of the cars they represent.  
   
 This parameter gains it's power in being able to deal with not requiring such a collection of association ids, as we could represent the same bulk loaded operation with     
 
```
bulk_load :cars, Garage::Client::Car, attribute: :user_id, from: :id 
```  
Assuming that the Garage::Client::Car endpoint supports querying by user_id, this then fetches a user's cars by that user's id instead of already knowing the id's of it's cars.   
  
`autoload`  
Autoload being set to true will automatically push it's 'from' values into the bulk queue on the object's initialization. If this isn't set, you must manually push the association into the queue per object like:  
`` my_api_user.queue_association(:cars)``  
This adds it to the bulk loading queue and upon calling .cars, will fetch all queued associations for that client model (sort of). 
  
A fun part of manually queueing assocations is a parameter that you get from this - There are times where you don't want the entire association, but maybe the first few items of it. To keep batch fetch sizes small (and shit fast), you can manually push only a portion of the associated ids using the limit argument.  
`` my_api_user.queue_association(:cars, 5)``  
will only fetch the first 5 of the user's cars.   

  **This currently gets weird if you aren't using the whole *_ids appoach to fetching related records. **  
  
*But what if my relation is a has_one!?*  

in addition to `bulk_load`, there is `bulk_load_has_one`. This accepts the same arguments of the previous, but simply calls .first on the returned association. woooo 

#### FAncy MAGicKs 
A bulk-load-association-enabled client model will do two things differently when using this gem.  
1) On initialization, for it's autoloaded associations, it will push the needed id's for that association onto to loading queue. 
  
2) When any object who's association is autoloaded actually calls that association, all queued id's for said association are bundled together and called. This means that if another object with the same association has that association hit after the first object, there is no second call to the service, as that object's associated objects have already been fetched and are sitting in the temporary bulk fetch store. 