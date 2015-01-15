###Problem 1:  
  Your auto garage application has it's own backend with a particular model. Lets call it User. You have the idea to extract the User to it's own service, but aren't quite ready to fully transition to your Garage::Client::User model.  
    
###Solution 1:  
  A common pattern would be to just tack a method onto the User model that gives you the corresponding Garage::Client::User model. This gem adds a method to ActiveRecord::Base that allows you do to 'bind' a method in an AR model to it's API counterpart. For our user, it looks like:  

```
class User < ActiveRecord::Base

  bind_to_api_model User::Client::User
  
end

user = User.find(4)
user.api_obj
>> Garage::Client::User
```

This, by default creates a method to access a User's corresponding client model via ``my_user.api_obj``. What this method is called can be changed with the optional second argument.  

```
class User < ActiveRecord::Base

  bind_to_api_model Garage::Client::User, :client_user
  
end

user = User.find(4)
user.client_user
>> Garage::Client::User
```  

Keep in mind that because this functionality is tied into the later explained "somewhat eager lazy loading", the client call isn't actually made until you call the method. Simply put - it doesn't hit the API until it needs to.  


###Problem 2
Your User model has a 1-n relation with Cars, which itself has a 1-n relation with FancyUpgrades. For some reason, your API User model represents it's Cars with an attribute car_ids, which contains the ids of the cars that user owns. The same is the case for the fancy upgrades. So this is goddamn wonderful.. that is until you want to display a page containing many users with small snippets of information about their cars and the fancy upgrades those cars have. You're smart and grab the  Users from the client. woooo. But as you iterate, you realize that you're hitting the Garage::Client::Cars endpoint once per user, and the Garage::Client::FancyUpgrades endpoint a metric shitton of times. Shit.  
  
###Solution 2 
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
