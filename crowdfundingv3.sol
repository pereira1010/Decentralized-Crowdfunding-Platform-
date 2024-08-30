// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingPlatform {
    
    struct Milestone {
        uint256 amount;
        string description;
        bool approved;
        uint256 votes;
        mapping(address => bool) voted;
    }
    
    struct Campaign {
        uint256 id;
        string name;
        string description;
        uint256 targetAmount;
        uint256 totalContributed;
        uint256 deadline;
        address payable creator;
        bool finalized;
        uint256 milestoneCount;
        address[] contributors;  // Store contributors' addresses
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(uint256 => Milestone)) public milestones;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    uint256 public campaignCount;
    
    event CampaignCreated(uint256 indexed campaignID, string name, string description, uint256 targetAmount, uint256 deadline, address creator);
    event ContributionMade(uint256 indexed campaignID, address indexed contributor, uint256 amount);
    event MilestoneApproved(uint256 indexed campaignID, uint256 indexed milestoneIndex);
    event FundsReleased(uint256 indexed campaignID, uint256 indexed milestoneIndex);
    event RefundClaimed(uint256 indexed campaignID, address indexed contributor, uint256 amount);
    event CampaignFinalized(uint256 indexed campaignID, string status);

    modifier onlyCreator(uint256 campaignID) {
        require(msg.sender == campaigns[campaignID].creator, "Only campaign creator can call this function");
        _;
    }

function createCampaign(string memory name, string memory description, uint256 targetAmount, uint256 deadline) public {
    require(deadline > block.timestamp, "Deadline must be in the future");
    campaignCount++;
    
    campaigns[campaignCount] = Campaign({
        id: campaignCount,
        name: name,
        description: description,
        targetAmount: targetAmount,
        totalContributed: 0,
        deadline: deadline,
        creator: payable(msg.sender),
        finalized: false,
        milestoneCount: 0,
        contributors: new address[] (0) // Initialize as an empty array
    });

    emit CampaignCreated(campaignCount, name, description, targetAmount, deadline, msg.sender);
}

    function addMilestone(uint256 campaignID, uint256 amount, string memory description) public onlyCreator(campaignID) {
        Campaign storage campaign = campaigns[campaignID];
        uint256 milestoneIndex = campaign.milestoneCount;
        
        Milestone storage newMilestone = milestones[campaignID][milestoneIndex];
        newMilestone.amount = amount;
        newMilestone.description = description;
        newMilestone.approved = false;
        newMilestone.votes = 0;
        
        campaign.milestoneCount++;
    }

    function contribute(uint256 campaignID, uint256 amount) public payable {
        Campaign storage campaign = campaigns[campaignID];
        require(block.timestamp < campaign.deadline, "Campaign deadline has passed");
        require(campaign.totalContributed < campaign.targetAmount, "Campaign target has been reached");
        require(amount == msg.value, "Sent value does not match the input amount");

        // Add contributor to the list if it's their first contribution
        if (contributions[campaignID][msg.sender] == 0) {
            campaign.contributors.push(msg.sender);
        }

        contributions[campaignID][msg.sender] += amount;
        campaign.totalContributed += amount;
        
        emit ContributionMade(campaignID, msg.sender, amount);
    }

    function approveMilestone(uint256 campaignID, uint256 milestoneIndex) public {
        Campaign storage campaign = campaigns[campaignID];

        // Ensure that the milestone exists
        require(milestoneIndex < campaign.milestoneCount, "Milestone does not exist");

        require(contributions[campaignID][msg.sender] > 0, "You are not a contributor");

        Milestone storage milestone = milestones[campaignID][milestoneIndex];
        require(!milestone.voted[msg.sender], "You have already voted on this milestone");

        milestone.votes++;
        milestone.voted[msg.sender] = true;

        if (milestone.votes > campaign.contributors.length / 2) {
            milestone.approved = true;
            campaign.creator.transfer(milestone.amount);
            emit FundsReleased(campaignID, milestoneIndex);
        }

        emit MilestoneApproved(campaignID, milestoneIndex);
    }


    function claimRefund(uint256 campaignID) public {
    Campaign storage campaign = campaigns[campaignID];
    require(block.timestamp > campaign.deadline, "Campaign is still active");
    require(campaign.totalContributed < campaign.targetAmount, "Campaign was successful, no refunds");

    uint256 refundAmount = contributions[campaignID][msg.sender];
    require(refundAmount > 0, "No contributions found");

    contributions[campaignID][msg.sender] = 0;
    payable(msg.sender).transfer(refundAmount);
    emit RefundClaimed(campaignID, msg.sender, refundAmount);
}


    function finalizeCampaign(uint256 campaignID) public onlyCreator(campaignID) {
        Campaign storage campaign = campaigns[campaignID];
        require(!campaign.finalized, "Campaign already finalized");
        require(block.timestamp > campaign.deadline || allMilestonesApproved(campaignID), "Campaign not eligible for finalization");
        
        campaign.finalized = true;
        string memory status = campaign.totalContributed >= campaign.targetAmount ? "successful" : "failed";
        emit CampaignFinalized(campaignID, status);
    }

    function getCampaignDetails(uint256 campaignID) public view returns (string memory, string memory, uint256, uint256, uint256, address, bool) {
        Campaign storage campaign = campaigns[campaignID];
        return (
            campaign.name,
            campaign.description,
            campaign.targetAmount,
            campaign.totalContributed,
            campaign.deadline,
            campaign.creator,
            campaign.finalized
        );
    }

    function getContributorInfo(uint256 campaignID, address contributor) public view returns (uint256) {
        return contributions[campaignID][contributor];
    }

    function getMilestoneStatus(uint256 campaignID, uint256 milestoneIndex) public view returns (string memory, uint256, bool, uint256) {
        Milestone storage milestone = milestones[campaignID][milestoneIndex];
        return (
            milestone.description,
            milestone.amount,
            milestone.approved,
            milestone.votes
        );
    }

    function getAllCampaigns() public view returns (uint256[] memory) {
        uint256[] memory campaignIDs = new uint256[](campaignCount);
        for (uint i = 1; i <= campaignCount; i++) {
            campaignIDs[i - 1] = campaigns[i].id;
        }
        return campaignIDs;
    }

    function getCampaignContributors(uint256 campaignID) public view returns (address[] memory) {
        return campaigns[campaignID].contributors;
    }

    function getTotalContributions(uint256 campaignID) public view returns (uint256) {
        return campaigns[campaignID].totalContributed;
    }

    function getContributorCount(uint256 campaignID) internal view returns (uint256) {
        return campaigns[campaignID].contributors.length;
    }

    function allMilestonesApproved(uint256 campaignID) internal view returns (bool) {
        Campaign storage campaign = campaigns[campaignID];
        for (uint i = 0; i < campaign.milestoneCount; i++) {
            if (!milestones[campaignID][i].approved) {
                return false;
            }
        }
        return true;
    }
}

