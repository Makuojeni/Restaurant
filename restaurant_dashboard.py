"""
Restaurant Dashboard - Streamlit Application
ITOM6265 - Database Homework
Student: Jinegwo Makuo
"""

import streamlit as st
import pandas as pd
import mysql.connector
from mysql.connector import Error
import folium
import streamlit.components.v1 as components

# Page configuration with custom colors
st.set_page_config(
    page_title="ITOM6265-HW1", 
    page_icon="🍽️", 
    layout="wide", 
    initial_sidebar_state="expanded"
)

# Custom CSS with pink, purple, and light blue colors (Customization #1)
st.markdown("""
    <style>
    .main-header {
        font-size: 2.8rem;
        font-weight: bold;
        text-align: center;
        padding: 1.5rem;
        background: linear-gradient(90deg, #FF69B4 0%, #9370DB 50%, #87CEEB 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 1rem;
    }
    .info-box {
        padding: 1.5rem;
        border-radius: 15px;
        background-color: #f8f9fa;
        border-left: 6px solid #FF69B4;
        margin: 1rem 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .stButton>button {
        background: linear-gradient(90deg, #FF69B4 0%, #9370DB 100%);
        color: white;
        border: none;
        border-radius: 8px;
        padding: 0.5rem 1rem;
        font-weight: bold;
    }
    .metric-container {
        background: linear-gradient(135deg, #87CEEB 0%, #9370DB 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
    }
    </style>
""", unsafe_allow_html=True)

# Database connection
try:
    connection = mysql.connector.connect(
        host='db-mysql-itom-do-user-28250611-0.j.db.ondigitalocean.com',
        port=25060,
        user='restaurant_readonly',
        password='SecurePassword123!',
        database='restaurant'
    )
    db_connected = True
except Error as e:
    st.error(f"❌ Error connecting to MySQL Database: {e}")
    st.info("Please check your database credentials")
    db_connected = False
    connection = None

# Sidebar navigation with custom styling
st.sidebar.markdown("# 🍽️ Restaurant Dashboard")
st.sidebar.markdown("**Student:** Jinegwo Makuo")
st.sidebar.markdown("**Course:** ITOM6265")
st.sidebar.markdown("---")

if db_connected:
    st.sidebar.success("✅ Database connected!")
else:
    st.sidebar.error("❌ Database connection failed")

page = st.sidebar.radio(
    "Select a page:",
    ["📋 HW Summary", "🔍 Q1-Database Query", "🗺️ Q2-Maps"],
    label_visibility="visible"
)

# TAB 1: HW Summary
if page == "📋 HW Summary":
    st.markdown("<h1 class='main-header'>Restaurant Dashboard</h1>", unsafe_allow_html=True)
    
    # Student information with custom layout (Customization #2: Columns)
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.markdown("<div class='info-box'>", unsafe_allow_html=True)
        st.subheader("👤 Student Information")
        st.write("**Name:** Jinegwo Makuo")
        st.write("**Course:** ITOM6265")
        st.write("**Assignment:** Homework 1 - Restaurant Dashboard")
        st.write("**Date:** November 2025")
        st.markdown("</div>", unsafe_allow_html=True)
    
    with col2:
        st.markdown("<div class='info-box'>", unsafe_allow_html=True)
        st.subheader("📊 Dashboard Features")
        st.write("✅ Database Search with Filters")
        st.write("✅ Interactive Map with Markers")
        st.write("✅ Custom Color Scheme")
        st.write("✅ Enhanced Visualizations")
        st.markdown("</div>", unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Customizations description
    st.subheader("🎨 Customizations Implemented")
    
    st.markdown("""
    ### 1. **Custom Color Scheme (Pink, Purple, Light Blue)**
    - Applied gradient color scheme throughout the dashboard
    - Pink (#FF69B4), Purple (#9370DB), and Light Blue (#87CEEB)
    - Custom CSS styling for headers, buttons, and info boxes
    - Color-coordinated metrics and visual elements
    
    ### 2. **Enhanced Layout with Columns**
    - Two-column layout in HW Summary for better organization
    - Responsive design with custom containers
    - Info boxes with colored borders and shadows
    - Professional styling with rounded corners
    
    ### 3. **Custom Map Tiles (CartoDB Positron)**
    - Implemented CartoDB Positron tiles for clean map appearance
    - Blue markers with interactive popups
    - Provides better contrast than default OpenStreetMap
    - Professional and modern aesthetic
    """)
    
    st.info("📌 Navigate using the sidebar to explore Database Query and Interactive Map features!")

# TAB 2: Database Query
elif page == "🔍 Q1-Database Query":
    st.markdown("<h1 class='main-header'>Restaurant Database Search</h1>", unsafe_allow_html=True)
    
    if not db_connected:
        st.error("❌ Database connection not available. Please check your credentials.")
    else:
        # Get min and max votes
        try:
            table_query = """
            SELECT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'votes' 
            LIMIT 1
            """
            tbl_df = pd.read_sql(table_query, connection)
            votes_table = tbl_df['TABLE_NAME'][0] if not tbl_df.empty else 'business_location'
            
            votes_query = f"SELECT MIN(votes) as min_votes, MAX(votes) as max_votes FROM `{votes_table}` WHERE votes IS NOT NULL"
            votes_df = pd.read_sql(votes_query, connection)
            min_votes = int(votes_df['min_votes'][0]) if not votes_df.empty else 0
            max_votes = int(votes_df['max_votes'][0]) if not votes_df.empty else 1000
        except Exception as e:
            st.error(f"Error getting vote range: {e}")
            min_votes, max_votes = 0, 1000
            votes_table = 'business_location'
        
        # Layout with columns
        col1, col2 = st.columns([1, 2])
        
        with col1:
            st.markdown("### Filter Options")
            name_pattern = st.text_input(
                "Pattern of Name:", 
                value="", 
                help="Enter a substring to search within restaurant names (e.g. 'Pizza', 'Dishoom'). Leave empty to list all.", 
                placeholder="e.g., Dishoom"
            )
            vote_range = st.slider(
                "Range of votes to search for:", 
                min_value=min_votes, 
                max_value=max_votes, 
                value=(min_votes, max_votes), 
                help="Filter restaurants by their votes."
            )
            search_button = st.button("🔍 Get results", type="primary", use_container_width=True)
        
        with col2:
            st.markdown("### Search Results")
            
            if search_button:
                try:
                    # Build query based on filters
                    if name_pattern and name_pattern.strip() != "":
                        query = f"SELECT name, votes, city FROM `{votes_table}` WHERE votes BETWEEN %s AND %s AND name LIKE %s ORDER BY votes DESC"
                        params = (int(vote_range[0]), int(vote_range[1]), f"%{name_pattern}%")
                    else:
                        query = f"SELECT name, votes, city FROM `{votes_table}` WHERE votes BETWEEN %s AND %s ORDER BY votes DESC"
                        params = (int(vote_range[0]), int(vote_range[1]))
                    
                    results_df = pd.read_sql(query, connection, params=params)
                    
                    if not results_df.empty:
                        st.success(f"✅ Found {len(results_df)} restaurants")
                        
                        # Display results (Customization #3: Enhanced data display)
                        st.dataframe(
                            results_df.reset_index(drop=True), 
                            use_container_width=True, 
                            height=400, 
                            hide_index=True, 
                            column_config={
                                "name": st.column_config.TextColumn("Restaurant Name"),
                                "votes": st.column_config.NumberColumn("Votes", format="%d"),
                                "city": st.column_config.TextColumn("City")
                            }
                        )
                        
                        # Show statistics with custom styling
                        st.markdown("---")
                        col_a, col_b, col_c = st.columns(3)
                        with col_a:
                            st.metric("📊 Total Results", len(results_df))
                        with col_b:
                            st.metric("📈 Avg Votes", f"{results_df['votes'].mean():.0f}")
                        with col_c:
                            st.metric("⭐ Max Votes", f"{results_df['votes'].max():.0f}")
                    else:
                        st.warning("⚠️ No restaurants found matching your criteria.")
                        
                except Exception as e:
                    st.error(f"❌ An error occurred while querying the database: {e}")

# TAB 3: Interactive Map
elif page == "🗺️ Q2-Maps":
    st.markdown("<h1 class='main-header'>Restaurant Map</h1>", unsafe_allow_html=True)
    
    if not db_connected:
        st.error("❌ Database connection not available. Please check your connection settings.")
    else:
        # Center the button
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            display_map = st.button("🗺️ Display map!", type="primary", use_container_width=True)
            st.caption("Map of restaurants in London. Click on teardrop to check names.")
        
        if display_map:
            try:
                # Get table with coordinates
                coord_query = """
                SELECT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME IN ('latitude','longitude') 
                GROUP BY TABLE_NAME 
                HAVING SUM(CASE WHEN COLUMN_NAME='latitude' THEN 1 ELSE 0 END) > 0 
                AND SUM(CASE WHEN COLUMN_NAME='longitude' THEN 1 ELSE 0 END) > 0 
                LIMIT 1
                """
                coord_tbl = pd.read_sql(coord_query, connection)
                coord_table = coord_tbl['TABLE_NAME'][0] if not coord_tbl.empty else 'business_location'
                
                # Query location data
                loc_query = f"SELECT name, latitude, longitude FROM `{coord_table}` WHERE latitude IS NOT NULL AND longitude IS NOT NULL"
                locations_df = pd.read_sql(loc_query, connection)
            except Exception as e:
                st.error(f"❌ Could not fetch location data: {e}")
                locations_df = pd.DataFrame(columns=['name', 'latitude', 'longitude'])
            
            if locations_df.empty:
                st.warning("⚠️ No valid restaurant coordinates were found to display on the map.")
            else:
                # Create Folium map with custom tiles
                london_map = folium.Map(
                    location=[51.5074, -0.1278], 
                    zoom_start=11, 
                    tiles='CartoDB positron'
                )
                
                # Add blue markers for each restaurant
                marker_count = 0
                for idx, row in locations_df.iterrows():
                    try:
                        lat = float(row['latitude'])
                        lon = float(row['longitude'])
                        name = str(row['name'])
                        
                        folium.Marker(
                            location=[lat, lon],
                            popup=name,
                            tooltip=name,
                            icon=folium.Icon(color='blue')
                        ).add_to(london_map)
                        marker_count += 1
                    except Exception as e:
                        continue
                
                st.success(f"✅ Successfully mapped {marker_count} restaurants")
                
                # Display map using HTML rendering
                map_html = london_map._repr_html_()
                
                # Use iframe to display the map
                import streamlit.components.v1 as components
                components.html(map_html, height=700, scrolling=False)
                
                # Show statistics
                st.markdown("---")
                col_a, col_b, col_c = st.columns(3)
                with col_a:
                    st.metric("🍽️ Total Restaurants", len(locations_df))
                with col_b:
                    st.metric("📍 Avg Latitude", f"{locations_df['latitude'].mean():.4f}")
                with col_c:
                    st.metric("📍 Avg Longitude", f"{locations_df['longitude'].mean():.4f}")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #7f8c8d; font-size: 0.9em;'>
    ITOM6265 Database Management | Restaurant Dashboard | Built with Streamlit | Student: Jinegwo Makuo
</div>
""", unsafe_allow_html=True)

# Close database connection
if connection and connection.is_connected():
    connection.close()
