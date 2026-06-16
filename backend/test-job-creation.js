require('dotenv').config();
const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

async function testJobCreation() {
  console.log('=== Testing Job Creation API ===\n');

  try {
    // Create a test job
    console.log('1. Creating a test job...');
    const jobData = {
      title: 'Software Developer',
      description: 'Looking for an experienced Flutter developer for a mobile app project in Khartoum.',
      company: 'Tech Solutions Sudan',
      phone: '912345678',
      sector: 'Programming',
      jobType: 'Full-time',
      salaryText: '50,000 - 80,000 SDG',
      location: 'Khartoum, SD',
      budget: 0
    };

    const createResponse = await axios.post(`${BASE_URL}/jobs`, jobData);
    console.log('✓ Job created successfully');
    console.log('Response:', JSON.stringify(createResponse.data, null, 2));
    
    const jobId = createResponse.data.jobId;
    console.log(`✓ Job ID: ${jobId}\n`);

    // Fetch all jobs
    console.log('2. Fetching all jobs...');
    const getResponse = await axios.get(`${BASE_URL}/jobs`);
    console.log('✓ Jobs fetched successfully');
    console.log(`✓ Total jobs: ${getResponse.data.count}`);
    console.log('Jobs:', JSON.stringify(getResponse.data.jobs, null, 2));
    console.log('\n');

    // Fetch jobs by sector
    console.log('3. Fetching jobs by sector (Programming)...');
    const sectorResponse = await axios.get(`${BASE_URL}/jobs?sector=Programming`);
    console.log('✓ Jobs fetched by sector');
    console.log(`✓ Jobs in Programming: ${sectorResponse.data.count}`);
    console.log('Jobs:', JSON.stringify(sectorResponse.data.jobs, null, 2));
    console.log('\n');

    // Fetch specific job
    console.log(`4. Fetching job by ID (${jobId})...`);
    const jobResponse = await axios.get(`${BASE_URL}/jobs/${jobId}`);
    console.log('✓ Job fetched by ID');
    console.log('Job:', JSON.stringify(jobResponse.data.job, null, 2));
    console.log('\n');

    console.log('=== All tests passed! ✓ ===');

  } catch (error) {
    console.error('✗ Test failed:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    }
    process.exit(1);
  }
}

testJobCreation();
