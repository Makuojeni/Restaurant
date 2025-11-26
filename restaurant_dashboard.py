import streamlit as st
import mysql.connector
import pandas as pd
import folium
from streamlit_folium import st_folium

# Page configuration
st.set_page_config(
    page_title="Restaurant Dashboard",
    page_icon="🍽️",
    layout="wide"
)

# Custom CSS for styling (Customization #1: Enhanced styling)
st.markdown("""
    <style>
    .main-header {
        font-size: 2.5rem;
        color: #FF6B6B;
        text-align: center;
        padding: 1rem;
        background: linear-gradient(90deg, #FF6B6B 0%, #4ECDC4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .info-box {
        padding: 1.5rem;
        border-radius: 10px;
        background-color: #f0f2f6;
        border-left: 5px solid #FF6B6B;
        margin: 1rem 0;
    }
    </style>
""", unsafe_allow_html=True)

# Database connection function
@st.cache_resource
def get_database_connection():
    """Establish database connection with credentials"""
    try:
        connection = mysql.connector.connect(
            host='db-mysql-itom-do-user-28250611-0.j.db.ondigitalocean.com',
            port=25060,
            user='restaurant_readonly',
            password='SecurePassword123!',
            database='restaurant'
        )
        return connection
    except mysql.connector.Error as err:
        st.error(f"❌ Database connection failed: {err}")
        return None

# Test database connection
connection = get_database_connection()
if connection:
    st.sidebar.success("✅ Database connected successfully!")
else:
    st.sidebar.error("❌ Database connection failed!")

# Sidebar navigation
st.sidebar.title("🍽️ Navigation")
tab_selection = st.sidebar.radio(
    "Select a page:",
    ["📋 HW Summary", "🔍 Database Query", "🗺️ Interactive Map"]
)

# Tab 1: HW Summary
if tab_selection == "📋 HW Summary":
    st.markdown("<h1 class='main-header'>Restaurant Dashboard</h1>", unsafe_allow_html=True)
    
    # Customization #1: Using columns for layout
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.markdown("<div class='info-box'>", unsafe_allow_html=True)
        st.subheader("👤 Student Information")
        st.write("**Name:** Jinegwo Makuo")
        st.write("**Course:** ITOM6265")
        st.write("**Assignment:** Homework 1 - Restaurant Dashboard")
        st.write("**Date:** November 2024")
        st.markdown("</div>", unsafe_allow_html=True)
    
    with col2:
        st.markdown("<div class='info-box'>", unsafe_allow_html=True)
        st.subheader("📊 Dashboard Features")
        st.write("✅ Database Search Functionality")
        st.write("✅ Interactive Map with Markers")
        st.write("✅ Custom Visualizations")
        st.markdown("</div>", unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Customizations description
    st.subheader("🎨 Customizations Implemented")
    
    st.markdown("""
    ### 1. **Layout Enhancement (Columns & Containers)**
    - Used two-column layout in HW Summary for better organization
    - Applied custom CSS styling with gradient headers
    - Created info boxes with colored borders for visual appeal
    
    ### 2. **Custom Map Tiles**
    - Implemented CartoDB Positron tiles for a clean, modern map appearance
    - Alternative option: CartoDB Dark_Matter for dark mode aesthetic
    - Provides better contrast than default OpenStreetMap
    
    ### 3. **Enhanced Data Display**
    - Styled tables with color-coded metrics
    - Added custom CSS for headers with gradient effects
    - Implemented visual feedback with success/error messages
    - Used emojis and icons throughout for better UX
    """)
    
    st.info("📌 Navigate using the sidebar to explore Database Query and Interactive Map features!")

# Tab 2: Database Query
elif tab_selection == "🔍 Database Query":
    st.markdown("<h1 class='main-header'>Restaurant Database Search</h1>", unsafe_allow_html=True)
    
    if connection:
        # Get min and max votes from database for slider
        cursor = connection.cursor()
        cursor.execute("SELECT MIN(votes), MAX(votes) FROM business_location WHERE votes IS NOT NULL")
        min_votes, max_votes = cursor.fetchone()
        cursor.close()
        
        # Default to 0 if no data
        min_votes = int(min_votes) if min_votes else 0
        max_votes = int(max_votes) if max_votes else 1000
        
        # Customization #1: Using columns for input layout
        col1, col2 = st.columns([2, 1])
        
        with col1:
            # Text input for restaurant name
            restaurant_name = st.text_input(
                "🏪 Restaurant Name Pattern",
                placeholder="Enter restaurant name (e.g., Dishoom)",
                help="Leave empty to show all restaurants"
            )
        
        with col2:
            st.write("")  # Spacing
        
        # Vote range slider
        vote_range = st.slider(
            "📊 Vote Range",
            min_value=min_votes,
            max_value=max_votes,
            value=(min_votes, max_votes),
            help="Filter restaurants by number of votes"
        )
        
        # Search button
        if st.button("🔍 Get results", type="primary"):
            try:
                cursor = connection.cursor()
                
                # Build SQL query with filters
                query = """
                    SELECT name, votes, city
                    FROM business_location
                    WHERE votes BETWEEN %s AND %s
                """
                params = [vote_range[0], vote_range[1]]
                
                # Add name filter if provided
                if restaurant_name:
                    query += " AND name LIKE %s"
                    params.append(f"%{restaurant_name}%")
                
                query += " ORDER BY votes DESC"
                
                # Execute query
                cursor.execute(query, params)
                results = cursor.fetchall()
                cursor.close()
                
                # Display results
                if results:
                    st.success(f"✅ Found {len(results)} restaurant(s)")
                    
                    # Convert to DataFrame for better display (Customization #3)
                    df = pd.DataFrame(results, columns=['Restaurant Name', 'Votes', 'City'])
                    
                    # Style the dataframe
                    st.dataframe(
                        df,
                        use_container_width=True,
                        hide_index=True
                    )
                    
                    # Show statistics
                    col1, col2, col3 = st.columns(3)
                    with col1:
                        st.metric("Total Results", len(results))
                    with col2:
                        st.metric("Avg Votes", f"{df['Votes'].mean():.0f}")
                    with col3:
                        st.metric("Max Votes", f"{df['Votes'].max():.0f}")
                else:
                    st.warning("⚠️ No restaurants found matching your criteria.")
                    
            except mysql.connector.Error as err:
                st.error(f"❌ Query error: {err}")
    else:
        st.error("❌ Database connection not available. Please check your credentials.")

# Tab 3: Interactive Map
elif tab_selection == "🗺️ Interactive Map":
    st.markdown("<h1 class='main-header'>Restaurant Locations Map</h1>", unsafe_allow_html=True)
    
    if connection:
        st.caption("Map of restaurants in London. Click on teardrop to check names.")
        
        # Display map button
        if st.button("🗺️ Display map!", type="primary"):
            with st.spinner("Loading map..."):
                try:
                    # Query location data
                    query = """
                        SELECT name, latitude, longitude
                        FROM business_location
                        WHERE latitude IS NOT NULL 
                        AND longitude IS NOT NULL
                    """
                    
                    # Use pandas to execute query
                    df_locations = pd.read_sql(query, connection)
                    
                    if not df_locations.empty:
                        st.success(f"✅ Displaying {len(df_locations)} restaurants on map")
                        
                        # Create map centered on London
                        m = folium.Map(
                            location=[51.5074, -0.1278],
                            zoom_start=12,
                            tiles='CartoDB positron'
                        )
                        
                        # Add markers for each restaurant
                        for idx, row in df_locations.iterrows():
                            folium.Marker(
                                location=[row['latitude'], row['longitude']],
                                popup=folium.Popup(row['name'], max_width=200),
                                tooltip=row['name'],
                                icon=folium.Icon(color='blue', icon='info-sign')
                            ).add_to(m)
                        
                        # Display map
                        st_folium(m, width=1200, height=600)
                        
                        # Show map statistics
                        st.markdown("---")
                        col1, col2, col3 = st.columns(3)
                        with col1:
                            st.metric("🍽️ Total Restaurants", len(df_locations))
                        with col2:
                            st.metric("📍 Avg Latitude", f"{df_locations['latitude'].mean():.4f}")
                        with col3:
                            st.metric("📍 Avg Longitude", f"{df_locations['longitude'].mean():.4f}")
                    else:
                        st.warning("⚠️ No restaurant locations found in database.")
                        
                except Exception as err:
                    st.error(f"❌ Error creating map: {err}")
        else:
            st.info("👆 Click the button above to display the restaurant map!")
    else:
        st.error("❌ Database connection not available. Please check your credentials.")

# Footer
st.sidebar.markdown("---")
st.sidebar.markdown("**Restaurant Dashboard v1.0**")
st.sidebar.markdown("Built with Streamlit 🎈")
