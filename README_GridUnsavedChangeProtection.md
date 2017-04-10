#### Overview

When users work with the grid, their changes are not imediately reflected in the database.

There is an element of usability 'safety' where they can work for quite a while,<br />
only to loose **all of it** because they navigated away or hit the delete key in the wrong spot.

This can be even further of an issue because of automated changes and the user may not even know they need to save.

#### How do we fix it?

There are two main areas that changes must be made.

** This must be done on every grid that requires protection **

##### VisualForce (page containing the grid)

**1. Add to the head of the VF page:**

	<script type="text/javascript" src="{!URLFOR($Resource.LNE_vf_shared_js, 'gridUnsavedChangePrompt.js')}"></script>  

**2. When the DOM is ready in the init / bootstrapper function on the VF page, add:**

	lneSharedJs.handleFocusLoss(); 
		
If this is the only js on the page just ensure it runs at the end of the body markup or in a document ready block

**3. Add the following html attribute to the grid iframe:**

 		data-grid-name="" 

**NOTE: The grid name should be the same name you see in the gridbuddy iframe SRC EXCEPT - No spaces! All lower case!**
		
For example:

	        <div class="grid-container" id="grid-container-productionmiscellaneous">
	            <!-- Production/Miscellaneous Grid -->
	            <iframe id="grid-frame-productionmiscellaneous" data-grid-name="productionmiscellaneous" data-grid-visible="" scrolling="auto" height="480" width="100%" frameborder="0" src="{!gridPage}gname=Production-Miscellaneous&fpf=AdPlan__c&fpv={!Id}&sbb=0&sh=0&ssb=0"></iframe>
	        </div>


#### Grid JavaScript

**1. Inside the document ready / main init / bootstrapper function:**

	gridSpecificHandleFocusLoss();

**REMINDER: the grunt compile will add the function to your grid specific file so it will be available.**