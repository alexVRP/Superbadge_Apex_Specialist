//public with sharing class WarehouseCalloutService {
//
//    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
//
//    // complete this method to make the callout (using @future) to the
//    // REST endpoint and update equipment on hand.
//    @future(callout=true)
//    public static void runWarehouseEquipmentSync(){
//        Http http = new Http();
//        HttpRequest request = new HttpRequest();
//        request.setEndpoint(WAREHOUSE_URL);
//        request.setMethod('GET');
//        HttpResponse response = http.send(request);
//        // If the request is successful, parse the JSON response.
//        if (response.getStatusCode() == 200) {
//            // Deserialize the JSON string into collections of primitive data types.
//            List<Object> equipments = (List<Object>) JSON.deserializeUntyped(response.getBody());
//            List<Product2> products = new List<Product2>();
//            for(Object o :  equipments){
//                Map<String, Object> mapProduct = (Map<String, Object>)o;
//                Product2 product = new Product2();
//                product.Name = (String)mapProduct.get('name');
//                product.Cost__c = (Integer)mapProduct.get('cost');
//                product.Current_Inventory__c = (Integer)mapProduct.get('quantity');
//                product.Maintenance_Cycle__c = (Integer)mapProduct.get('maintenancePeriod');
//                product.Replacement_Part__c = (Boolean)mapProduct.get('replacement');
//                product.Lifespan_Months__c = (Integer)mapProduct.get('lifespan');
//                product.Warehouse_SKU__c = (String)mapProduct.get('sku');
//                product.ProductCode = (String)mapProduct.get('_id');
//                products.add(product);
//            }
//            if(products.size() > 0){
//                System.debug(products);
//                upsert products;
//            }
//        }
//    }
//
//}



public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    private static final String GET = 'GET';

    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.

    @future (callout=true)
    public static void runWarehouseEquipmentSync(){
        List<Product2> upsertList = new List<Product2>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod(GET);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        String JSONContent = res.getBody().replaceAll('_id', 'equipmentId');
        JSONParser parser = JSON.createParser(JSONContent);

        while (parser.nextValue() == JSONToken.START_ARRAY) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Equipment inv = (Equipment)parser.readValueAs(Equipment.class);
                        upsertList.add(new Product2(Lifespan_Months__c = inv.lifespan,
                                Cost__c = inv.cost,
                                Replacement_Part__c = true,
                                Maintenance_Cycle__c = inv.maintenancePeriod,
                                Warehouse_SKU__c = inv.sku,
                                Current_Inventory__c = inv.quantity,
                                Name = inv.name));
                        parser.skipChildren();
                    }
                }
            }
        }
        upsert upsertList Warehouse_SKU__c;
    }

    public class Equipment {
        public String equipmentId;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenancePeriod;
        public Integer lifespan;
        public Integer cost;
        public String sku;

    }

}