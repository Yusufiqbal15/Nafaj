require('dotenv').config();
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

const sampleJobs = [
  {
    title: 'Delivery Driver',
    description: 'We are looking for a reliable delivery driver to join our team. Must have a valid driving license and knowledge of Khartoum streets.',
    company: 'Nafaj Delivery Services',
    phone: '912345001',
    sector: 'Driver',
    jobType: 'Full-time',
    salaryText: '30,000 - 40,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Web Designer',
    description: 'Creative web designer needed for e-commerce projects. Experience with Figma and modern web design principles required.',
    company: 'Digital Sudan Agency',
    phone: '912345002',
    sector: 'Web Design',
    jobType: 'Full-time',
    salaryText: '45,000 - 65,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'English Teacher',
    description: 'Experienced English teacher needed for private tutoring sessions. Must be fluent in English and Arabic.',
    company: 'Smart Learning Center',
    phone: '912345003',
    sector: 'Teaching',
    jobType: 'Part-time',
    salaryText: '150 SDG per hour',
    location: 'Omdurman, SD',
    budget: 0
  },
  {
    title: 'Construction Worker',
    description: 'Skilled construction workers needed for residential building project. Experience in masonry and carpentry preferred.',
    company: 'BuildRight Contractors',
    phone: '912345004',
    sector: 'Construction',
    jobType: 'Contract',
    salaryText: '35,000 - 50,000 SDG',
    location: 'Bahri, SD',
    budget: 0
  },
  {
    title: 'Graphic Designer',
    description: 'Talented graphic designer needed for branding and marketing materials. Proficiency in Adobe Creative Suite required.',
    company: 'Creative Hub Sudan',
    phone: '912345005',
    sector: 'Graphic Design',
    jobType: 'Full-time',
    salaryText: '40,000 - 60,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Accountant',
    description: 'Certified accountant needed for financial management and reporting. Experience with accounting software required.',
    company: 'Finance Solutions Ltd',
    phone: '912345006',
    sector: 'Accounting & Finance',
    jobType: 'Full-time',
    salaryText: '50,000 - 75,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Restaurant Server',
    description: 'Friendly and efficient restaurant servers needed. Previous experience in food service preferred.',
    company: 'Golden Fork Restaurant',
    phone: '912345007',
    sector: 'Hospitality',
    jobType: 'Full-time',
    salaryText: '25,000 - 30,000 SDG + tips',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Mobile App Developer',
    description: 'Experienced Flutter/React Native developer needed for mobile app projects. Portfolio required.',
    company: 'AppWorks Sudan',
    phone: '912345008',
    sector: 'Technology & IT',
    jobType: 'Full-time',
    salaryText: '60,000 - 100,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Security Guard',
    description: 'Responsible security guards needed for night shifts. Must be physically fit and alert.',
    company: 'SafeGuard Security',
    phone: '912345009',
    sector: 'Security',
    jobType: 'Full-time',
    salaryText: '28,000 - 35,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Electrician',
    description: 'Licensed electrician needed for residential and commercial electrical work.',
    company: 'PowerPro Services',
    phone: '912345010',
    sector: 'Electrician',
    jobType: 'Contract',
    salaryText: '40,000 - 55,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Marketing Manager',
    description: 'Experienced marketing manager to lead digital marketing campaigns and brand strategy.',
    company: 'MarketPro Sudan',
    phone: '912345011',
    sector: 'Marketing & Sales',
    jobType: 'Full-time',
    salaryText: '70,000 - 100,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  },
  {
    title: 'Cleaner',
    description: 'Reliable cleaners needed for office buildings. Morning shifts available.',
    company: 'CleanSweep Services',
    phone: '912345012',
    sector: 'Cleaning',
    jobType: 'Part-time',
    salaryText: '20,000 - 25,000 SDG',
    location: 'Khartoum, SD',
    budget: 0
  }
];

async function addSampleJobs() {
  console.log('=== Adding Sample Jobs to Database ===\n');

  let successCount = 0;
  let failCount = 0;

  for (const job of sampleJobs) {
    try {
      console.log(`Adding: ${job.title} (${job.sector})...`);
      const response = await axios.post(`${BASE_URL}/jobs`, job);
      
      if (response.data.success) {
        console.log(`✓ Added successfully (ID: ${response.data.jobId})\n`);
        successCount++;
      } else {
        console.log(`✗ Failed: ${response.data.error}\n`);
        failCount++;
      }
    } catch (error) {
      console.error(`✗ Error: ${error.message}\n`);
      failCount++;
    }
  }

  console.log('======================');
  console.log(`✓ Successfully added: ${successCount} jobs`);
  console.log(`✗ Failed: ${failCount} jobs`);
  console.log('======================\n');

  // Fetch and display summary
  try {
    const response = await axios.get(`${BASE_URL}/jobs`);
    console.log(`\n📊 Total jobs in database: ${response.data.count}`);
    
    // Count by sector
    const sectorCounts = {};
    response.data.jobs.forEach(job => {
      const sector = job.sector || 'Unknown';
      sectorCounts[sector] = (sectorCounts[sector] || 0) + 1;
    });

    console.log('\nJobs by sector:');
    Object.entries(sectorCounts).sort((a, b) => b[1] - a[1]).forEach(([sector, count]) => {
      console.log(`  ${sector}: ${count}`);
    });
  } catch (error) {
    console.error('Error fetching summary:', error.message);
  }
}

addSampleJobs();
