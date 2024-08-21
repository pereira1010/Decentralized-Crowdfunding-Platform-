// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // Enum to track the status of a campaign
    enum CampaignStatus { Active, Successful, Failed }

    // Struct to represent a Milestone within a campaign
    struct Milestone {
        string description;   // Description of the milestone
        uint256 amount;       // Amount of ETH needed to reach this milestone
        bool approved;        // Whether this milestone has been approved by contributors
        uint256 votes;        // Number of votes for this milestone
        mapping(address => bool) voters; // Tracks who has voted for this milestone
    }

    // Struct to represent a Campaign
    struct Campaign {
        uint256 id;               // Unique identifier for the campaign
        string name;              // Descriptive title of the campaign
        string description;       // Detailed information about the campaign's purpose
        uint256 targetAmount;     // The total amount of ETH the campaign aims to raise
        uint256 deadline;         // Timestamp for the end of the fundraising period
        address payable creator;  // Ethereum address of the campaign creator
        uint256 totalRaised;      // Total amount of ETH raised so far
        uint256 milestoneCount;   // Number of milestones in the campaign
        CampaignStatus status;    // Current status of the campaign
        mapping(uint256 => Milestone) milestones; // Mapping of milestone index to Milestone
        mapping(address => uint256) contributions; // Mapping of contributor addresses to their contributions
    }

    // Mapping to track all campaigns by ID
    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount = 0; // Counter to generate unique campaign IDs

    // Events to log important actions in the contract
    event CampaignCreated(uint256 indexed campaignId, string name, address creator);
    event ContributionMade(uint256 indexed campaignId, address contributor, uint256 amount);
    event MilestoneApproved(uint256 indexed campaignId, uint256 milestoneIndex);
    event FundsReleased(uint256 indexed campaignId, uint256 milestoneIndex, uint256 amount);
    event RefundClaimed(uint256 indexed campaignId, address contributor, uint256 amount);
    event CampaignFinalized(uint256 indexed campaignId, CampaignStatus status);

    // Function to create a new campaign
    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _targetAmount,
        uint256 _deadline,
        string[] memory _milestoneDescriptions,
        uint256[] memory _milestoneAmounts
    ) public {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_milestoneDescriptions.length == _milestoneAmounts.length, "Milestone data mismatch");

        campaignCount++;
        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.id = campaignCount;
        newCampaign.name = _name;
        newCampaign.description = _description;
        newCampaign.targetAmount = _targetAmount;
        newCampaign.deadline = _deadline;
        newCampaign.creator = payable(msg.sender);
        newCampaign.status = CampaignStatus.Active;

        for (uint256 i = 0; i < _milestoneDescriptions.length; i++) {
            Milestone storage milestone = newCampaign.milestones[i];
            milestone.description = _milestoneDescriptions[i];
            milestone.amount = _milestoneAmounts[i];
        }
        newCampaign.milestoneCount = _milestoneDescriptions.length;

        emit CampaignCreated(campaignCount, _name, msg.sender);
    }

    // Function to contribute ETH to a campaign
    function contribute(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(campaign.status == CampaignStatus.Active, "Campaign is not active");
        require(msg.value > 0, "Contribution must be greater than zero");

        campaign.contributions[msg.sender] += msg.value;
        campaign.totalRaised += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    // Function to approve a milestone
    function approveMilestone(uint256 _campaignId, uint256 _milestoneIndex) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(campaign.status == CampaignStatus.Active, "Campaign is not active");
        require(campaign.contributions[msg.sender] > 0, "Only contributors can vote");

        Milestone storage milestone = campaign.milestones[_milestoneIndex];
        require(!milestone.voters[msg.sender], "You have already voted for this milestone");

        milestone.voters[msg.sender] = true;
        milestone.votes++;

        // If more than 50% of contributors approve, release funds
        if (milestone.votes * 2 > getTotalContributors(_campaignId)) {
            milestone.approved = true;
            campaign.creator.transfer(milestone.amount);

            emit FundsReleased(_campaignId, _milestoneIndex, milestone.amount);
        }

        emit MilestoneApproved(_campaignId, _milestoneIndex);
    }

    // Function to claim a refund if the campaign fails
    function claimRefund(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(campaign.status != CampaignStatus.Successful, "Successful campaign; refunds not available");
        require(campaign.contributions[msg.sender] > 0, "You have no contributions to refund");

        uint256 refundAmount = campaign.contributions[msg.sender];
        campaign.contributions[msg.sender] = 0; // Prevent double claims

        payable(msg.sender).transfer(refundAmount);

        emit RefundClaimed(_campaignId, msg.sender, refundAmount);
    }

    // Function to finalize the campaign
    function finalizeCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(msg.sender == campaign.creator, "Only the campaign creator can finalize");

        if (campaign.totalRaised >= campaign.targetAmount) {
            campaign.status = CampaignStatus.Successful;
        } else {
            campaign.status = CampaignStatus.Failed;
        }

        emit CampaignFinalized(_campaignId, campaign.status);
    }

    // View function to get details of a specific campaign
    function getCampaignDetails(uint256 _campaignId) public view returns (
        string memory name,
        string memory description,
        uint256 targetAmount,
        uint256 deadline,
        address creator,
        uint256 totalRaised,
        CampaignStatus status
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.name,
            campaign.description,
            campaign.targetAmount,
            campaign.deadline,
            campaign.creator,
            campaign.totalRaised,
            campaign.status
        );
    }

    // View function to get a contributor's details for a specific campaign
    function getContributorInfo(uint256 _campaignId, address _contributor) public view returns (
        uint256 contributionAmount
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (campaign.contributions[_contributor]);
    }

    // View function to get milestone status for a specific campaign
    function getMilestoneStatus(uint256 _campaignId, uint256 _milestoneIndex) public view returns (
        string memory description,
        uint256 amount,
        bool approved,
        uint256 votes
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        Milestone storage milestone = campaign.milestones[_milestoneIndex];
        return (
            milestone.description,
            milestone.amount,
            milestone.approved,
            milestone.votes
        );
    }

    // View function to get the total number of contributors for a specific campaign
    function getTotalContributors(uint256 _campaignId) public view returns (uint256) {
        Campaign storage campaign = campaigns[_campaignId];
        uint256 contributorCount = 0;
        for (uint256 i = 0; i < campaign.milestoneCount; i++) {
            if (campaign.contributions[msg.sender] > 0) {
                contributorCount++;
            }
        }
        return contributorCount;
    }
}
