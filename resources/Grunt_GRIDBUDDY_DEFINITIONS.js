/**
 *  Module that defines the list of modules that you'll use with grunt
 *  so the package file doesn't need to be updated all the @#$@#$ time.
 *  @author Paul Roth <proth@salesforce.com>
**/

/** CSS to add **/
var commonCSS = ['grunt_src/lib/common.css'];
var commonExpensesCSS = ['grunt_src/CommonExpenses.css'];
var insertionCSS = commonCSS.concat(['grunt_src/components/insertionWidget.css']);

/** Scripts to add before the current script **/
var commonScripts = ['grunt_src/lib/underscore_1_8_3.js','grunt_src/lib/GridBuddyHelperScripts.js'];
var commonScripts2 = ['grunt_src/lib/underscore_1_8_3.js','grunt_src/lib/GridBuddyHelperScripts2.js'];

var bonusHelperScripts = commonScripts.concat(['grunt_src/bonushelpers.js']);
var bonusHelperScriptsUS641 = commonScripts.concat(['grunt_src/bonushelpersUS641.js']);
var copromoterScripts = commonScripts.concat(['grunt_src/copromoterHelpers.js']);
var eventReceiverScripts = commonScripts.concat(['grunt_src/lib/LNE_PostMessage.js']);
var gridBuddyCommScripts = commonScripts.concat(['grunt_src/lib/LNE_PostMessage2.js','grunt_src/lib/LNE_MessagePostOffice.js']);
var insertionWidgetScripts = commonScripts.concat(['grunt_src/lib/moment.min.js','grunt_src/components/insertionWidget.js']);


//-- could do this as a class, but this works for now.
//-- could do this as a JSON file, but comments are not supported.
module.exports = {
	js: {

		performingrightsfees: {
			src: 'grunt_src/performingrightsfees.js',
			beforeSrc: [commonScripts, gridBuddyCommScripts]
		},

		eventdatetime: {
			src: 'grunt_src/eventdatetime.js',
			beforeSrc: commonScripts
		},

		expensehousenut: {
			src: 'grunt_src/expensehousenut.js',
			beforeSrc: commonScripts
		},

		//-- custom scripts here
		/*
		//-- full example
		//-- name of the javaScript file - i.e.: gb_template_js.js
		template: {
			//-- path to your file to envelop around
			src: 'grunt_src/template.js',
			//-- optional set of scripts to include before the src
			beforeSrc: commonScripts,
			//-- optional set of scripts to include after src
			afterSrc: ['grunt_src/blank.file'],
		},
		*/

		//-- template to run a specific script
		/*
		template: {
			src: 'grunt_src/template.js',
			beforeSrc: commonScripts
		},
		*/	
		additions: {
			src: 'grunt_src/additions.js',
			beforeSrc: commonScripts
		},	
		afteradjusteddeductions: {
			src: 'grunt_src/afteradjusteddeductions.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenues: {
			src: 'grunt_src/ancillaryrevenues.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuespaul: {
			src: 'grunt_src/ancillaryrevenuespaul.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuesseb: {
			src: 'grunt_src/ancillaryrevenuesseb.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuesdom: {
			src: 'grunt_src/ancillaryrevenuesdom.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuesnewrecordv1: {
			src: 'grunt_src/ancillaryrevenuesnewrecordv1.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuesnewrecordv1b: {
			src: 'grunt_src/ancillaryrevenuesnewrecordv1b.js',
			beforeSrc: commonScripts
		},
		ancillaryrevenuedatacards: {
			src: 'grunt_src/ancillaryrevenuedatacards.js',
			beforeSrc: commonScripts
		},
		artistdeal: {
			src: ['grunt_src/artistdeal.js',
				'grunt_src/artistDealBonusDefinition.js',
				'grunt_src/artistRetroBonusDefinition.js'],
			beforeSrc: [commonScripts, bonusHelperScripts]
		},
		artistdealsettlement: {
			src: ['grunt_src/artistdealsettlement.js',
				'grunt_src/artistDealSettlementBonusDefinition.js',
				'grunt_src/artistRetroSettlementBonusDefinition.js'],
			beforeSrc: [commonScripts, bonusHelperScripts]
		},
		ArtistDeal_US641: {
			src: ['grunt_src/ArtistDeal_US641.js',
				'grunt_src/artistDealBonusDefinition.js',
				'grunt_src/artistRetroBonusDefinition.js'],
			beforeSrc: [commonScripts, bonusHelperScriptsUS641]
		},
		beforeadjusteddeductions: {
			src: 'grunt_src/beforeadjusteddeductions.js',
			beforeSrc: commonScripts
		},
		bonushelpers: {
			src: 'grunt_src/bonushelpers.js',
			beforeSrc: commonScripts
		},
		cogsexpenses: {
			src: 'grunt_src/cogsexpenses.js',
			beforeSrc: commonScripts
		},
		deductions: {
			src: 'grunt_src/deductions.js',
			beforeSrc: commonScripts
		},	
		digital: {
			src: 'grunt_src/digital.js',
			beforeSrc: commonScripts
		},
		Digital_US513: {
			src: 'grunt_src/Digital_US513.js',
			beforeSrc: commonScripts
		},
		expenses: {
			src: 'grunt_src/expenses.js',
			beforeSrc: commonScripts
		},
		expensesnako: {
			src: 'grunt_src/expensesnako.js',
			beforeSrc: commonScripts
		},
		financecogsexpenses: {
			src: 'grunt_src/financecogsexpenses.js',
			beforeSrc: commonScripts
		},
		financeancillaryrevenues: {
			src: 'grunt_src/financeancillaryrevenues.js',
			beforeSrc: commonScripts
		},
		FlashGrid_US634: {
			src: 'grunt_src/FlashGrid_US634.js',
			beforeSrc: commonScripts
		},
		flashgrid: {
			src: 'grunt_src/flashgrid.js',
			beforeSrc: commonScripts
		},
		outdoor: {
			src: 'grunt_src/outdoor.js',
			beforeSrc: commonScripts
		},
		Outdoor_US516: {
			src: 'grunt_src/Outdoor_US516.js',
			beforeSrc: commonScripts
		},
		platinumliftcalculator: {
			src: 'grunt_src/platinumliftcalculator.js',
			beforeSrc: commonScripts
		},
		primarycopromoters: {
			src: ['grunt_src/primarycopromoters.js'],
			beforeSrc: [bonusHelperScripts, copromoterScripts]
		},
		print: {
			src: 'grunt_src/print.js',
			beforeSrc: insertionWidgetScripts
		},
		print_US515: {
			src: 'grunt_src/print_US515.js',
			beforeSrc: insertionWidgetScripts
		},
		productionmiscellaneous: {
			src: 'grunt_src/productionmiscellaneous.js',
			beforeSrc: commonScripts
		},
		promotionsgrid: {
			src: 'grunt_src/promotionsgrid.js',
			beforeSrc: gridBuddyCommScripts
		},
		radio: {
			src: 'grunt_src/radio.js',
			beforeSrc: insertionWidgetScripts
		},
		radiotestgridoverlay: {
			src: 'grunt_src/radiotestgridoverlay.js',
			beforeSrc: eventReceiverScripts
		},
		secondarycopromoters: {
			src: ['grunt_src/secondarycopromoters.js'],
			beforeSrc: [bonusHelperScripts, copromoterScripts]
		},
		settlementexpenses: {
			src: ['grunt_src/SettlementExpenseHelper.js',
				  'grunt_src/settlementexpenses.js'],
			beforeSrc: [commonScripts, gridBuddyCommScripts]
		},
		settlementexpensehousenut: {
			src: ['grunt_src/SettlementExpenseHelper.js',
				  'grunt_src/settlementexpensehousenut.js'],
			beforeSrc: [commonScripts, gridBuddyCommScripts]
		},
		television: {
			src: 'grunt_src/television.js',
			beforeSrc: insertionWidgetScripts
		},
		Television_US512: {
			src: 'grunt_src/Television_US512.js',
			beforeSrc: insertionWidgetScripts
		},

		ticketaudit: {
			src: 'grunt_src/ticketaudit.js',
			beforeSrc: commonScripts
		},
		ticketscale: {
			src: 'grunt_src/ticketscale.js',
			beforeSrc: commonScripts
		},
		ticketscaleanubhav: {
			src: 'grunt_src/ticketscaleanubhav.js',
			beforeSrc: commonScripts
		},
		touradplanswithcampaigns: {
			src: 'grunt_src/touradplanswithcampaigns.js',
			beforeSrc: commonScripts
		},
		tourcampaign: {
			src: 'grunt_src/tourcampaign.js',
			beforeSrc: commonScripts
		},	
		tourspecificoverhead: {
			src: 'grunt_src/tourspecificoverhead.js',
			beforeSrc: commonScripts
		},
		US220_TourSpecificOverhead: {
			src: 'grunt_src/US220_TourSpecificOverhead.js',
			beforeSrc: commonScripts
		}
	},

	css: {
		flashgrid: {
			src: 'grunt_src/flashgrid.css',
			beforeSrc: commonCSS
		},
		ancillaryrevenuedatacards: {
			src: 'grunt_src/ancillaryrevenuedatacards.css',
			beforeSrc: commonCSS
			//afterSrc: ['grunt_src/blank2.file']
		},
		ancillaryrevenuesnewrecordv1: {
			src: 'grunt_src/ancillaryrevenuesnewrecordv1.css',
			beforeSrc: commonCSS
		},
		artistdeal: {
			src: 'grunt_src/artistdeal.css',
			beforeSrc: commonCSS
		},
		artistdealsettlement: {
			src: 'grunt_src/artistdealsettlement.css',
			beforeSrc: commonCSS
		},
		cogsexpenses: {
			src: 'grunt_src/cogsexpenses.css',
			beforeSrc: commonCSS
		},
		digital: {
			src: 'grunt_src/digital.css',
			beforeSrc: commonCSS
		},
		Digital_US513: {
			src: 'grunt_src/Digital_US513.css',
			beforeSrc: commonCSS
		},
		expenses: {
			src: commonExpensesCSS
		},
		expensehousenut: {
			src: commonExpensesCSS
		},
		flashgrid: {
			src: 'grunt_src/flashgrid.css',
			beforeSrc: commonCSS
		},
		outdoor: {
			src: 'grunt_src/outdoor.css',
			beforeSrc: commonCSS
		},
		primarycopromoters: {
			src: 'grunt_src/primarycopromoters.css',
			beforeSrc: commonCSS
		},
		print: {
			src: 'grunt_src/print.css',
			beforeSrc: insertionCSS
		},
		promotionsgrid: {
			src: 'grunt_src/promotionsgrid.css',
			beforeSrc: commonCSS
		},
		secondarycopromoters: {
			src: 'grunt_src/secondarycopromoters.css',
			beforeSrc: commonCSS
		},
		Outdoor_US516: {
			src: 'grunt_src/Outdoor_US516.css',
			beforeSrc: commonCSS
		},
		print_US515: {
			src: 'grunt_src/print_US515.css',
			beforeSrc: insertionCSS
		},
		productionmiscellaneous: {
			src: 'grunt_src/productionmiscellaneous.css',
			beforeSrc: commonCSS
		},
		radio: {
			src: 'grunt_src/radio.css',
			beforeSrc: insertionCSS
		},
		settlementexpenses: {
			src: commonExpensesCSS
		},
		settlementexpensehousenut: {
			src: commonExpensesCSS
		},
		television: {
			src: 'grunt_src/television.css',
			beforeSrc: insertionCSS
		},
		Television_US512: {
			src: 'grunt_src/Television_US512.css',
			beforeSrc: insertionCSS
		},
		template: {
			src: 'grunt_src/template.css',
			beforeSrc: commonCSS
			//afterSrc: ['grunt_src/blank2.file']
		}
	}
};
