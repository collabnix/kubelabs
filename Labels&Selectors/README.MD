# Labels and Selectors
In this tutorial we will learn how labels and selectors work in Kubernetes using two examples.
1) How Service uses a selector to map the pod to the backend as endpoints
2) How Pod can be scheduled on custom node using a selector

# How Service uses a Selector to Map the POD
In kubernetes, each pod will have a metadata definition underwhich we can define its name and labels. Labels help kubernetes to indentify the object for filtering and group purposes. Label uses key:value syntax , usualy each pod will have unique labels defined.
Lets getting into the demo part now

# Creating a Pod with Labels


 
