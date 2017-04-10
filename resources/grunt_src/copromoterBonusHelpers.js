
jq(document).ready(function() {

    /** 
    *   fieldInfo details what fields are listed on each new row the helper works with
    *
    *   type: @string      'drop' or 'text'
    *       the type should be text or drop. Used for example, reading back a dropdown value sometimes gb will display
    *       a text value for existing row until you click in then get select.
    *       The code will check for the placeholder el or select el to determine the value of a drop field
    *
    *   order: @integer     1 or higher the left to right order the value is rendered
    *       the order value should be 1 or higher, we assune that every row always has the 0 entry as checkbox/delete icon
    *
    *
    */
    var fieldInfoPrimary = {
        fields : {
            BonusBase__c: {
                type: 'drop',
                order: 1,
                prepop: 'true'
            },
            Type__c: {
                type: 'drop',
                order: 2,
                prepop: 'true'
            },
            BonusAmount__c: {
                type: 'text',
                order: 3,
                prepop: 'false'
            },
            rangeStart: {
                type: 'text',
                order: 4,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 5,
                prepop: 'false'
            },
            Increment__c: {
                type: 'text',
                order: 6,
                prepop: 'true'
            }      
        },
        uniqueness: 'copromoter',
        tableNewRowLabel: 'Create new Bonus Detail',
        humanGridName: 'Primary Co-Promoter',
        shortGridName: 'primary'
    };

    var fieldInfoSecondary = {
        fields : {
            BonusBase__c: {
                type: 'drop',
                order: 1,
                prepop: 'true'
            },
            Type__c: {
                type: 'drop',
                order: 2,
                prepop: 'true'
            },
            BonusAmount__c: {
                type: 'text',
                order: 3,
                prepop: 'false'
            },
            rangeStart: {
                type: 'text',
                order: 4,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 5,
                prepop: 'false'
            },
            Increment__c: {
                type: 'text',
                order: 6,
                prepop: 'true'
            }      
        },
        uniqueness: 'copromoter',
        tableNewRowLabel: 'Create new Bonus Detail',
        humanGridName: 'Secondary Co-Promoter',
        shortGridName: 'secondary'
    };

    var copromoterBonusPrimary = new BonusHelp(fieldInfoPrimary);
    var copromoterBonusSecondary = new BonusHelp(fieldInfoSecondary);

});

