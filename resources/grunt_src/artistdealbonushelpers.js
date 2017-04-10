
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
    var fieldInfoRetro = {
        fields : {
            rangeStart: {
                type: 'text',
                order: 1,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 2,
                prepop: 'false'
            }
        },
        uniqueness: 'artistretro',
        tableNewRowLabel: 'Create new Artist Retro/Step Up Detail',
        tableOrder: 1,
        humanGridName: 'Artist Retro/Step Up',
        shortGridName: 'retro'
    };

    var artistDealBonus = new BonusHelp(fieldInfoRetro);
    
    var fieldInfoDeal = {
        fields : {
            BonusBase__c: {
                type: 'drop',
                order: 1,
                prepop: 'false'
            },
            Type__c: {
                type: 'drop',
                order: 2,
                prepop: 'false'
            },
            ApplyTo__c: {
                type: 'drop',
                order: 3,
                prepop: 'false'
            },
            BonusAmount__c: {
                type: 'text',
                order: 4,
                prepop: 'false'
            },
            rangeStart: {
                type: 'text',
                order: 6,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 7,
                prepop: 'false'
            },
            Increment__c: {
                type: 'text',
                order: 8,
                prepop: 'true'
            }      
        },
        uniqueness: 'artistdeal',
        tableNewRowLabel: 'Create new Bonus Detail',
        tableOrder: 2,
        humanGridName: 'Bonus Detail',
        shortGridName: 'deal'
    };

    var artistDealBonus = new BonusHelp(fieldInfoDeal);
});
