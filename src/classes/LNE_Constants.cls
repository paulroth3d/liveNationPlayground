/**
 * Created by JK on 11/7/16.
 */

public with sharing class LNE_Constants {

    public static final String AD_BUY_TYPE_REGULAR = 'Regular Buy';
    public static final String AD_BUY_TYPE_PKG_DATES = 'Pkg. Deal (select dates)';
    public static final String AD_BUY_TYPE_PKG_RANGE = 'Pkg. Deal (date range)';

    public static final String EVENT_STATUS_DRAFT = 'Draft';
    public static final String EVENT_STATUS_PENDING_UNLIKELY = 'Pending Unlikely';
    public static final String EVENT_STATUS_PENDING_LIKELY = 'Pending Likely';
    public static final String EVENT_STATUS_CONFIRMED = 'Confirmed';
    public static final String EVENT_STATUS_CANCELLED = 'Cancelled';
    public static final String EVENT_STATUS_FLASH_STARTED = 'Flash Started';
    public static final String EVENT_STATUS_FLASH_COMPLETE = 'Flash Complete';
    public static final String EVENT_STATUS_ARTIST_PASSED = 'Artist Passed';
    public static final String EVENT_STATUS_LNE_PASSED = 'LNE Passed';
    public static final String EVENT_STATUS_POSTPONED = 'Postponed';
    public static final String EVENT_STATUS_INACTIVE = 'Inactive';

    public static final String TICKET_SCALE_STAGE_TYPE_PLAN = 'Plan';
    public static final String TICKET_SCALE_STAGE_TYPE_PROJECTION = 'Projection';
    public static final String TICKET_SCALE_STAGE_TYPE_OBSOLETE = 'Obsolete';

    public static final Set<String> TICKET_SCALE_PLAN_EVENT_STATUSES = new Set<String>{EVENT_STATUS_DRAFT, EVENT_STATUS_PENDING_UNLIKELY, EVENT_STATUS_PENDING_LIKELY};
    public static final Set<String> TICKET_SCALE_PROJECTION_EVENT_STATUSES = new Set<String>{EVENT_STATUS_CONFIRMED};

    public static final Set<String> MASS_MANUAL_TICKET_COUNT_EVENT_STATUS = new Set<String>{EVENT_STATUS_PENDING_LIKELY, EVENT_STATUS_CONFIRMED, EVENT_STATUS_FLASH_STARTED, EVENT_STATUS_FLASH_COMPLETE};

}