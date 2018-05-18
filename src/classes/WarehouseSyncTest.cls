/**
 * Created by ataeva on 18.05.2018.
 */

@IsTest
private class WarehouseSyncTest {
    @IsTest
    static void testScheduledJob() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobid = System.schedule('EquipTest', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();
        CronTrigger ct = [SELECT State FROM CronTrigger WHERE ID = :jobId];
        System.assertEquals('WAITING', String.valueOf(ct.State));
    }
}