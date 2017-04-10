<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ArtistDataReview</fullName>
        <description>Artist Data Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>ArtistDataReview</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MasterDataNotifications/ArtistDataReviewTemplate</template>
    </alerts>
    <alerts>
        <fullName>CoPromoterDataReview</fullName>
        <description>Co-Promoter Data Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>CoPromoterDataReview</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MasterDataNotifications/CoPromoterDataReviewTemplate</template>
    </alerts>
    <alerts>
        <fullName>SponsorDataReview</fullName>
        <description>Sponsor Data Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>SponsorDataReview</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MasterDataNotifications/SponsorDataReviewTemplate</template>
    </alerts>
    <alerts>
        <fullName>VendorDataReview</fullName>
        <description>Vendor Data Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>VendorDataReview</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MasterDataNotifications/VendorDataReviewTemplate</template>
    </alerts>
</Workflow>
