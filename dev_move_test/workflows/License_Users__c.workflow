<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Trial_Seat_Notification</fullName>
        <description>New Trial Seat Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Trial_Seat_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>License_AccountID_Update</fullName>
        <field>AccountID__c</field>
        <formula>License__r.Account__r.Id</formula>
        <name>License AccountID Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_License_Seat_To_Trial_If_No_Purchas</fullName>
        <description>Set the license seat field to trial</description>
        <field>Seat_Status__c</field>
        <literalValue>Trial</literalValue>
        <name>Set License Seat To Trial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Seat_Active</fullName>
        <description>Set the license seat to Active</description>
        <field>Seat_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Seat Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Seat_Expired</fullName>
        <description>Expire the seat</description>
        <field>Seat_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Set Seat Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_UniqueLicenseUserKey_Field</fullName>
        <description>Sets the unique key on the License Users object to enforce unique values</description>
        <field>UniqueLicenseUserKey__c</field>
        <formula>License__c + &apos;_&apos; + Contact__c</formula>
        <name>Update UniqueLicenseUserKey Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>License User Account Copy Rule</fullName>
        <actions>
            <name>License_AccountID_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>License__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This rule is used to copy the account value into the License User record so that lookup filters can be applied restricting the contacts to the account selected.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Trial Seat Notification</fullName>
        <actions>
            <name>New_Trial_Seat_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>License_Users__c.Seat_Status__c</field>
            <operation>equals</operation>
            <value>Trial</value>
        </criteriaItems>
        <description>Fires when a new trial seat is created letting the user know it is active</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set License Seat To Trial Based On Available Seats</fullName>
        <actions>
            <name>Set_License_Seat_To_Trial_If_No_Purchas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>License__c.Available_Seats__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>If a new license seat is created and there are no available purchased seats then set the license seat to Trial</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set License To Active If Seats Available</fullName>
        <actions>
            <name>Set_Seat_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>License__c.Available_Seats__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Set the license seat being created/edited to Active if there are any available aka purchased seats</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Seat Expired</fullName>
        <active>false</active>
        <criteriaItems>
            <field>License_Users__c.Seat_Status__c</field>
            <operation>equals</operation>
            <value>Trial</value>
        </criteriaItems>
        <description>Starts a time based event to expire the license seat after 30 days if the seat is still in Trial</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Seat_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Unique Key on License Users Record</fullName>
        <actions>
            <name>Update_UniqueLicenseUserKey_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Concatenate license and contact ids to keep records in this table unique</description>
        <formula>!ISBLANK(Contact__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
