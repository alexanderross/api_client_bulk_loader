##API Client Bulk Loader
A batch-loading mechanism for json api client. Provides an easy means to load relations for many service-backed models with a minimal amount of requests.


###What? 
The bulk loader creates a layer between models' association accessor methods and the service-backed requests used to fetch them. This layer will accumulate a list of resources to fetch corresponding to these accessors and will fetch them only when requested. What this enables is an efficient and easy means of consuming an API that's heavily heirarchal.  
  


###Usage
For simplicity, usage illustrates configuring within the client itself. Configuring in the application is possible using class_evals on client models.

#### Associations

The bulk loader provides a method that subscribes to the bulk loading layer to retrieve the records that it corresponds to. We can create these layers in a few fun ways.

**with Big-Ass list of associated Ids**  
  

```  
class Content::Client::Question

	bulk_load :answers, Content::Client::Answer, autoload: true
	...
```  

So the first two arguments here are what we'd like the association to be called, and what client resource model represents it.  
  
  
What this will do is, when a Content::Client::Question is initialize, take the value of "answer_ids" from that question, shove them into the bulk loading queue for Content::Client::Answer, and continue initializing.  
  
If we take a question though and call answers, it hits this layer and does something interesting - The bulk load layer will take those answer ids, plus the ids requested by any other initialized questions(or whatever else may be subscribing to Answer), and fetch all of those records in 1 request. 

What about ```autoload```? This defaults to true and when true will automatically push the values into the bulk loading layer on initialization. If it is set to false, one must manually queue the association.



**with a foreign key**

```  
class Content::Client::Question

	bulk_load :answers, Content::Client::Answer, :from => :id, :as => :question_id

	...
```  

So here we can assume that our Question object has no data to get it's answers. But if our Answer endpoint supports filtering by question_id, we can then fetch the association with the question's id being the value of the "question_id" filter. Two new params are introduced here.  

```from```, quite literally, is where our values to query come *from*. In the case before it was set to "answer_ids", but we manually set it here to "id", meaning "we get our value to query *from* question.id".  
  
```as``` depicts what our queried values are *as* attributes of the related resource. In the case before it was set to "id", meaning that an item in our 'answer_ids' was an id of an answer. In this case, we set it to question_id. Tying both from and as together illustrates that calling "answers" will get all answers satisfying ```answer.question_id == question.id```

#### Polymorphic Associations

Polymorphics work similarly to normal associations, only instead of a single resource as the second argument, it expects a hash mapping the possible values of the type column to their respective resource client models. This could look like:   
  
```
poly_trans_table = {
  "topic" => Content::Client::Topic,
  "legal_guide" => Content::Client::LegalGuide,
  "question" => Content::Client::Question
}
```

and we'd declare the load like:  

```  
class Content::Client::Comment

	bulk_load_poly :document, poly_trans_table, has_one: true
	...
```  

So there's some assumption going on on the part of the loader - specifically with one familiar, and two new params:  

```from``` in this case, would be assumed as "document_id".  

```from_type``` in this case, would be assumed to be "document_type". From_type sets what attribute holds the polymorphic type that corresponds to the resolution hash provided.   

```has_one``` simply denotes the association as has one - so instead of returning  an array, it just calls .first on the result and gives you a singular record. The bulk load methods ```bulk_load_has_one``` and ```bulk_load_poly_has_one``` set this to true.